//
//  PendingLogsStore.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//
import Foundation
import CoreData

/// Stores pending request metadata temporarily in memory using an actor for concurrency safety.
actor PendingLogsStore {
    /// Metadata for a request being tracked.
    struct RequestData {
        let requestURL: String?
        let method: String?
        let body: Data?
        let startTime: Date

        /// Returns the URL path component from the request URL, if available.
        var endpoint: String? {
            guard let url = requestURL else { return nil }
            return URL(string: url)?.path
        }
    }

    /// Internal storage of request data keyed by ID.
    private var store: [String: RequestData] = [:]

    /// Stores request data associated with an identifier.
    /// - Parameters:
    ///   - id: Unique identifier for the request.
    ///   - data: The associated request metadata.
    func set(id: String, data: RequestData) {
        store[id] = data
    }

    /// Retrieves stored request data by identifier.
    /// - Parameter id: The identifier of the request.
    /// - Returns: Stored `RequestData` if available.
    func get(id: String?) -> RequestData? {
        guard let id else { return nil }
        return store[id]
    }

    /// Removes stored request data for the given identifier.
    /// - Parameter id: The identifier of the request to remove.
    func remove(id: String?) {
        guard let id else { return }
        store.removeValue(forKey: id)
    }
}

extension NSManagedObjectContext {
    /// Asynchronously performs a throwing block inside the context’s queue and awaits the result.
    /// - Parameter block: A closure that returns a value or throws.
    /// - Returns: The result of the closure if successful.
    func performAsync<T>(_ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    let result = try block()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
