//
//  LoggieNetworkTracker+Alamofire.swift
//  Loggie
//
//  Created by Claude on 2025.
//

import Foundation
import Alamofire
import LoggieNetwork

public extension LoggieNetworkTracker {
    /// Alamofire interceptor that captures and monitors network traffic.
    var interceptor: RequestInterceptor & EventMonitor {
        return LoggieNetworkInterceptor()
    }
}
