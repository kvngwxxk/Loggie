//
//  LoggieNetwork.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//
import Foundation
import Alamofire
import SwiftData
import Loggie

/// Namespace for LoggieNetwork features.
public enum LoggieNetwork {
    /// The shared tracker instance that controls network logging UI.
    nonisolated(unsafe) public static let tracker = LoggieNetworkTracker()
    
    nonisolated(unsafe) public static var printAPILatency: Bool = false
}
