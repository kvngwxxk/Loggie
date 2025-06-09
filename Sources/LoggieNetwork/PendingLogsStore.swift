//
//  PendingLogsStore.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//
import Foundation
import CoreData

actor PendingLogsStore {
    struct RequestData {
        let requestURL: String?
        let method: String?
        let body: Data?
        let startTime: Date
        var endpoint: String? {
            guard let url = requestURL else { return nil }
            return URL(string: url)?.path
        }
    }

    private var store: [String: RequestData] = [:]

    func set(id: String, data: RequestData) {
        store[id] = data
    }

    func get(id: String?) -> RequestData? {
        guard let id else { return nil }
        return store[id]
    }

    func remove(id: String?) {
        guard let id else { return }
        store.removeValue(forKey: id)
    }
}

extension NSManagedObjectContext {
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
