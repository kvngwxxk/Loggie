//
//  LogLevel.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//

public enum LogLevel: String, CaseIterable {
    case debug, log, info, warning, error

    var emoji: String {
        switch self {
        case .debug: return "🐞"
        case .log: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    var severity: Int {
        switch self {
        case .debug:   return 0
        case .log:     return 1
        case .info:    return 2
        case .warning: return 3
        case .error:   return 4
        }
    }
    
    func displayPrefix(usingEmoji: Bool, showLevel: Bool) -> String {
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
