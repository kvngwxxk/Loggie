// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import os

@inlinable
public func log(_ message: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line) {
    Loggie.shared.log(message, level: .log, file: file, function: function, line: line)
}

@inlinable
public func info(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.info(message, file: file, function: function, line: line)
}

@inlinable
public func debug(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.debug(message, file: file, function: function, line: line)
}

@inlinable
public func warning(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.warning(message, file: file, function: function, line: line)
}

@inlinable
public func error(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    Loggie.error(message, file: file, function: function, line: line)
}

public final class Loggie {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.loggie", category: "Loggie")
    private let printQueue = DispatchQueue(label: "com.loggie.print")
    private let fileQueue  = DispatchQueue(label: "com.loggie.file")
    private var fileURL: URL?
    
    nonisolated(unsafe) public static let shared = Loggie()
    
    nonisolated(unsafe) public static var enabledLevels: Set<LogLevel> = Set(LogLevel.allCases)
    nonisolated(unsafe) public static var useOSLog: Bool = false
    nonisolated(unsafe) public static var showEmojiInCommonLog: Bool = false
    nonisolated(unsafe) public static var showLevelInCommonLog = false
    nonisolated(unsafe) public static var showEmoji: Bool = true
    
    nonisolated(unsafe) public static var useFileLogging: Bool = false {
        didSet {
            let instance = Loggie.shared
            if useFileLogging {
                // 디렉터리 생성
                if !FileManager.default.fileExists(atPath: instance.defaultLogDirectory.path) {
                    try? FileManager.default.createDirectory(at: instance.defaultLogDirectory, withIntermediateDirectories: true)
                }
                // 파일 생성 & 저장
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
        let text = "\(level.displayPrefix(usingEmoji: Self.showEmojiInCommonLog, showLevel: Loggie.showLevelInCommonLog))\(prefix) \(message)\n"
        
        
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
        let text = "\(level.displayPrefix(usingEmoji: Self.showEmoji, showLevel: true))\(prefix) \(message)\n"
        
        
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
    @inlinable
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .debug, file: file, function: function, line: line)
    }
    
    @inlinable
    public static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.log(message, level: .log, file: file, function: function, line: line)
    }
    
    @inlinable
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .info, file: file, function: function, line: line)
    }
    
    @inlinable
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .warning, file: file, function: function, line: line)
    }
     
    @inlinable
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logFixedFormat(message, level: .error, file: file, function: function, line: line)
    }
}
