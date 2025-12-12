//
//  LoggieURLProtocol.swift
//  Loggie
//
//  Created by Claude on 2025.
//

import Foundation
import Loggie

/// A custom URLProtocol that intercepts URLSession network requests for logging.
public final class LoggieURLProtocol: URLProtocol {

    /// Key used to mark requests that have already been handled to prevent infinite loops.
    private static let handledKey = "X-Loggie-URLProtocol-Handled"

    /// Key used to store the request ID for tracking.
    private static let requestIDKey = "X-Loggie-ID"

    /// The underlying URLSession task used to perform the actual network request.
    private var dataTask: URLSessionDataTask?

    /// Accumulated response data.
    private var responseData: Data?

    /// The HTTP response received.
    private var httpResponse: HTTPURLResponse?

    /// The request ID for this request.
    private var requestID: String?

    /// Internal URLSession for making actual requests (without Loggie interception).
    private static let internalSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    // MARK: - URLProtocol Overrides

    public override class func canInit(with request: URLRequest) -> Bool {
        // Only intercept HTTP/HTTPS requests that haven't been handled yet
        guard let scheme = request.url?.scheme?.lowercased(),
              (scheme == "http" || scheme == "https") else {
            return false
        }

        // Check if this request has already been handled
        if URLProtocol.property(forKey: handledKey, in: request) != nil {
            return false
        }

        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        // Mark the request as handled to prevent infinite loops
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "LoggieURLProtocol", code: -1, userInfo: nil))
            return
        }

        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutableRequest)

        // Generate and store request ID
        let requestID = UUID().uuidString
        self.requestID = requestID
        mutableRequest.setValue(requestID, forHTTPHeaderField: Self.requestIDKey)

        // Store request metadata
        let formattedBody = transformedBodyData(from: request.httpBody, contentType: request.value(forHTTPHeaderField: "Content-Type"))

        Task {
            await PendingLogsStore.shared.set(id: requestID, data: .init(
                requestURL: request.url?.absoluteString,
                method: request.httpMethod,
                body: formattedBody,
                startTime: Date()
            ))
        }

        // Initialize response data accumulator
        responseData = Data()

        // Create and start the data task
        dataTask = Self.internalSession.dataTask(with: mutableRequest as URLRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                self.handleError(error)
                return
            }

            if let response = response {
                self.httpResponse = response as? HTTPURLResponse
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = data {
                self.responseData?.append(data)
                self.client?.urlProtocol(self, didLoad: data)
            }

            self.finishLoading()
        }

        dataTask?.resume()
    }

    public override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }

    // MARK: - Private Methods

    private func handleError(_ error: Error) {
        logResponse(error: error)
        client?.urlProtocol(self, didFailWithError: error)
    }

    private func finishLoading() {
        logResponse(error: nil)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func logResponse(error: Error?) {
        guard let requestID = requestID else { return }

        Task {
            guard let pendingData = await PendingLogsStore.shared.get(id: requestID) else {
                log("[URLProtocol] No matching request data found.")
                return
            }

            let context = CoreDataManager.shared.backgroundContext()
            do {
                try await context.performAsync {
                    let logEntry = LoggieNetworkLog(context: context)
                    logEntry.id = UUID()

                    let duration = Date().timeIntervalSince(pendingData.startTime) * 1000
                    logEntry.source = "URLSession"
                    logEntry.duration = duration
                    logEntry.timestamp = Date()
                    logEntry.endPoint = pendingData.endpoint
                    logEntry.requestURL = pendingData.requestURL
                    logEntry.method = pendingData.method

                    // Request body
                    if let data = pendingData.body {
                        if let prettyString = self.prettyPrintedJSONString(from: data) {
                            logEntry.requestBody = prettyString
                        } else {
                            logEntry.requestBody = "There is no request body."
                        }
                    } else {
                        logEntry.requestBody = "There is no request body."
                    }

                    // Response data
                    if let error = error {
                        logEntry.responseData = "Error: \(error.localizedDescription)"
                        logEntry.responseStatusCode = -1
                    } else if let data = self.responseData, !data.isEmpty {
                        if let prettyString = self.prettyPrintedJSONString(from: data) {
                            logEntry.responseData = prettyString
                        } else if let stringData = String(data: data, encoding: .utf8) {
                            logEntry.responseData = stringData
                        } else {
                            logEntry.responseData = "Binary data (\(data.count) bytes)"
                        }
                    } else {
                        logEntry.responseData = "There is no response data."
                    }

                    // Status code
                    if let httpResponse = self.httpResponse {
                        logEntry.responseStatusCode = Int16(httpResponse.statusCode)
                    }

                    // Print latency if enabled
                    if LoggieNetwork.printAPILatency {
                        print("[LoggieNetwork] [\(pendingData.endpoint ?? "Invalid EndPoint")] API Latency: \(duration) ms")
                    }

                    try context.save()
                }

                await PendingLogsStore.shared.remove(id: requestID)

            } catch {
                log("[URLProtocol] Failed to save response log: \(error)")
            }
        }
    }

    // MARK: - JSON Pretty Print Helpers

    private func prettyPrintedJSONString(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }

    private func prettyPrintedQueryStringData(from data: Data) -> Data? {
        guard let queryString = String(data: data, encoding: .utf8) else { return nil }
        var dict = [String: String]()
        queryString.components(separatedBy: "&").forEach { pair in
            let elements = pair.components(separatedBy: "=")
            if elements.count == 2 {
                dict[elements[0].removingPercentEncoding ?? ""] = elements[1].removingPercentEncoding ?? ""
            }
        }
        return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
    }

    private func transformedBodyData(from data: Data?, contentType: String?) -> Data? {
        guard let data = data else { return nil }

        if contentType?.contains("application/json") == true,
           let prettyString = prettyPrintedJSONString(from: data),
           let prettyData = prettyString.data(using: .utf8) {
            return prettyData
        } else if let prettyData = prettyPrintedQueryStringData(from: data) {
            return prettyData
        }
        return data
    }
}

// MARK: - URLSessionConfiguration Extension

public extension URLSessionConfiguration {
    /// Returns a URLSessionConfiguration with LoggieURLProtocol registered for network logging.
    static var loggieDefault: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [LoggieURLProtocol.self] + (config.protocolClasses ?? [])
        return config
    }

    /// Returns an ephemeral URLSessionConfiguration with LoggieURLProtocol registered for network logging.
    static var loggieEphemeral: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [LoggieURLProtocol.self] + (config.protocolClasses ?? [])
        return config
    }

    /// Registers LoggieURLProtocol with this configuration.
    func registerLoggie() {
        self.protocolClasses = [LoggieURLProtocol.self] + (self.protocolClasses ?? [])
    }
}
