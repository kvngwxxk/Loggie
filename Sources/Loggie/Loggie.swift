// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import os

/// Logs a message with `.log` level.
/// - Parameters:
///   - message: The message to be logged.
///   - file: The source file name. (Auto-injected)
///   - function: The function name. (Auto-injected)
///   - line: The line number. (Auto-injected)
@inlinable
public func log(_ message: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line) {
    Loggie.shared.log(message, level: .log, file: file, function: function, line: line)
}

@inlinable
public func log<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
    Loggie.shared.log(String(describing: object), level: .log, file: file, function: function, line: line)
}

/// Logs a message with `.info` level.
@inlinable
public func info(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.info(message, file: file, function: function, line: line)
}

/// Logs a message with `.debug` level.
@inlinable
public func debug(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.debug(message, file: file, function: function, line: line)
}

/// Logs a message with `.warning` level.
@inlinable
public func warning(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.warning(message, file: file, function: function, line: line)
}

/// Logs a message with `.error` level.
@inlinable
public func error(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.error(message, file: file, function: function, line: line)
}

/// The main logging utility class that manages console and file logging.
public final class Loggie {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.loggie", category: "Loggie")
    private let printQueue = DispatchQueue(label: "com.loggie.print")
    private let fileQueue  = DispatchQueue(label: "com.loggie.file")
    private var fileURL: URL?
    
    /// The shared singleton instance of `Loggie`.
    nonisolated(unsafe) public static let shared = Loggie()
    
    /// Controls which log levels are enabled.
    nonisolated(unsafe) public static var enabledLevels: Set<LogLevel> = Set(LogLevel.allCases)
    
    /// Whether to use Apple's unified logging system (OSLog).
    nonisolated(unsafe) public static var useOSLog: Bool = false
    
    /// Whether to show emoji in common log messages.
    nonisolated(unsafe) public static var showEmojiInCommonLog: Bool = false
    
    /// Whether to show log level labels in common logs.
    nonisolated(unsafe) public static var showLevelInCommonLog = false
    
    /// Whether to show emoji in fixed-format logs.
    nonisolated(unsafe) public static var showEmoji: Bool = true
    
    /// Enables or disables file logging.
    nonisolated(unsafe) public static var useFileLogging: Bool = false {
        didSet {
            let instance = Loggie.shared
            if useFileLogging {
                if !FileManager.default.fileExists(atPath: instance.defaultLogDirectory.path) {
                    try? FileManager.default.createDirectory(at: instance.defaultLogDirectory, withIntermediateDirectories: true)
                }
                let filename = "Loggie_\(instance.isoFormatter.string(from: Date())).log"
                let url = instance.defaultLogDirectory.appendingPathComponent(filename)
                if !FileManager.default.fileExists(atPath: url.path) {
                    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
                }
                instance.fileURL = url
            } else {
                instance.fileURL = nil
            }
        }
    }
    
    private let defaultLogDirectory: URL = {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return cwd.appendingPathComponent("Loggie", isDirectory: true)
    }()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    @usableFromInline
    internal func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard Self.enabledLevels.contains(level) else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        let prefix = "[\(fileName):\(function) @ \(line)]"
        let text = "\(level.displayPrefix(usingEmoji: Self.showEmojiInCommonLog, showLevel: Loggie.showLevelInCommonLog))\(prefix) \(message)"
        
        
        if Self.useOSLog {
            switch level {
            case .debug:
                logger.debug("\(text, privacy: .public)")
            case .log:
                logger.notice("\(text, privacy: .public)")
            case .info:
                logger.info("\(text, privacy: .public)")
            case .warning:
                logger.warning("\(text, privacy: .public)")
            case .error:
                logger.fault("\(text, privacy: .public)")
            }
        } else {
            printQueue.async { print(text) }
        }
        
        if let url = fileURL {
            fileQueue.async {
                guard let data = text.data(using: .utf8),
                      let handle = try? FileHandle(forWritingTo: url)
                else { return }
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        }
    }
    
    @usableFromInline
    internal func logFixedFormat(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard Self.enabledLevels.contains(level) else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        let prefix = "[\(fileName):\(function) @ \(line)]"
        let text = "\(level.displayPrefix(usingEmoji: Self.showEmoji, showLevel: true))\(prefix) \(message)"
        
        
        if Self.useOSLog {
            switch level {
            case .debug:
                logger.debug("\(text, privacy: .public)")
            case .log:
                logger.notice("\(text, privacy: .public)")
            case .info:
                logger.info("\(text, privacy: .public)")
            case .warning:
                logger.warning("\(text, privacy: .public)")
            case .error:
                logger.fault("\(text, privacy: .public)")
            }
        } else {
            printQueue.async { print(text) }
        }
        
        if let url = fileURL {
            fileQueue.async {
                guard let data = text.data(using: .utf8),
                      let handle = try? FileHandle(forWritingTo: url)
                else { return }
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        }
    }
}

extension Loggie {
    /// Logs a message at debug level.
    @inlinable
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Logs a message at log level.
    @inlinable
    public static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.log(message, level: .log, file: file, function: function, line: line)
    }
    
    /// Logs a message at info level.
    @inlinable
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Logs a message at warning level.
    @inlinable
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .warning, file: file, function: function, line: line)
    }
     
    /// Logs a message at error level.
    @inlinable
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .error, file: file, function: function, line: line)
    }
}
