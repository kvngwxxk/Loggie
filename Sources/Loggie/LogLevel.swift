//
//  LogLevel.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//

public enum LogLevel: String, CaseIterable {
    /// Debug-level logs, typically used for developer-level diagnostics.
    case debug

    /// General log-level messages, for tracing logic or general events.
    case log

    /// Informational messages that highlight the progress of the application.
    case info

    /// Warning messages for recoverable issues or potential problems.
    case warning

    /// Error messages for serious issues that need attention.
    case error

    /// An emoji representation for the log level, used in visual display.
    var emoji: String {
        switch self {
        case .debug: return "🐞"
        case .log: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }

    /// Numeric severity for sorting or filtering log levels.
    /// Lower number = lower severity.
    var severity: Int {
        switch self {
        case .debug:   return 0
        case .log:     return 1
        case .info:    return 2
        case .warning: return 3
        case .error:   return 4
        }
    }

    /// Returns a prefix string for log output based on emoji and level display options.
    /// - Parameters:
    ///   - usingEmoji: Whether to include emoji in the output.
    ///   - showLevel: Whether to include the log level text (e.g. [INFO])
    /// - Returns: Formatted prefix string
    internal func displayPrefix(usingEmoji: Bool, showLevel: Bool) -> String {
        let levelText = "[\(rawValue.uppercased())] "
        if usingEmoji && showLevel {
            return "\(emoji) \(levelText)"
        } else if usingEmoji && !showLevel {
            return "\(emoji) "
        } else if !usingEmoji && showLevel {
            return "\(levelText)"
        } else {
            return ""
        }
    }
}
