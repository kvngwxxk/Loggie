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

public enum LoggieNetwork {
    nonisolated(unsafe) public static let tracker = LoggieNetworkTracker()
}
