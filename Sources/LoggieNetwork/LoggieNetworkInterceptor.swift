//
//  LoggieNetworkInterceptor.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//

import Foundation
import Alamofire
import Loggie

final class LoggieNetworkInterceptor: RequestInterceptor, EventMonitor {
    let queue = DispatchQueue(label: "loggie.network.interceptor")
    private let pendingLogs = PendingLogsStore.shared

    // MARK: - RequestAdapter
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var mutableRequest = urlRequest
        let requestID = UUID().uuidString
        mutableRequest.setValue(requestID, forHTTPHeaderField: "X-Loggie-ID")

        let formattedBody: Data? = {
            guard let body = mutableRequest.httpBody else { return nil }
            let contentType = mutableRequest.value(forHTTPHeaderField: "Content-Type")
            return transformedBodyData(from: body, contentType: contentType)
        }()

        Task {
            await pendingLogs.set(id: requestID, data: .init(
                requestURL: mutableRequest.url?.absoluteString,
                method: mutableRequest.httpMethod,
                body: formattedBody,
                startTime: Date()
            ))
        }
        completion(.success(mutableRequest))
    }

    // MARK: - RequestRetrier
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let id = request.request?.value(forHTTPHeaderField: "X-Loggie-ID")
        Task { await pendingLogs.remove(id: id) }
        completion(.doNotRetry)
    }

    // MARK: - EventMonitor
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        guard let req = request.request,
              let requestID = req.value(forHTTPHeaderField: "X-Loggie-ID")
        else { return }
        
        Task {
            guard let pendingData = await pendingLogs.get(id: requestID) else {
                print("[Interceptor] 대응되는 request 데이터가 없습니다.")
                return
            }
            
            let context = CoreDataManager.shared.backgroundContext()
            do {
                try await context.performAsync {
                    let log = LoggieNetworkLog(context: context)
                    log.id = UUID()
                    
                    let duration = Date().timeIntervalSince(pendingData.startTime) * 1000
                    log.source = "App"
                    log.duration = duration
                    log.timestamp = Date()  // 응답 시각
                    log.endPoint = pendingData.endpoint
                    log.requestURL = pendingData.requestURL
                    log.method = pendingData.method
                    
                    if let data = pendingData.body {
                        if let prettyString = self.prettyPrintedJSONString(from: data) {
                            log.requestBody = prettyString
                        } else {
                            log.requestBody = "There is no request body."
                        }
                    } else {
                        log.requestBody = "There is no request body."
                    }
                    
                    if let data = response.data {
                        if let prettyString = self.prettyPrintedJSONString(from: data) {
                            log.responseData = prettyString
                        } else {
                            log.responseData = "There is no response data."
                        }
                    } else {
                        log.responseData = "There is no response data."
                    }
                    
                    if let httpResponse = response.response {
                        log.responseStatusCode = Int16(httpResponse.statusCode)
                    }
                    
                    print("[Interceptor] API Latency: \(duration) ms")
                    
                    try context.save()
                }
                
                await pendingLogs.remove(id: requestID)
                
            } catch {
                print("[Interceptor] Response 로그 저장 실패: \(error)")
            }
        }
    }

    // MARK: - JSON Pretty Print Helper
    private func prettyPrintedJSONString(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("JSON pretty print failed: \(error)")
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

    private func transformedBodyData(from data: Data, contentType: String?) -> Data {
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
