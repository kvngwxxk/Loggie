//
//  Bundle+Localization.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/24/25.
//

import Foundation
import ObjectiveC.runtime

private var overrideBundleKey: UInt8 = 0

extension Bundle {
    
    public static func enableDynamicLocalization() {
        struct Token { static var done = false }
        guard !Token.done else { return }
        Token.done = true
        
        let cls: AnyClass = Bundle.self
        let original = #selector(localizedString(forKey:value:table:))
        let swizzled = #selector(swizzled_localizedString(forKey:value:table:))
        
        if let origMethod = class_getInstanceMethod(cls, original),
           let swzMethod  = class_getInstanceMethod(cls, swizzled) {
            method_exchangeImplementations(origMethod, swzMethod)
        }
    }
    
    internal static func setOverrideLanguage(_ lang: Language) {
        guard
            let path = Bundle.module.path(forResource: lang.rawValue, ofType: "lproj"),
            let langBundle = Bundle(path: path)
        else {
            assertionFailure("'\(lang.rawValue).lproj' not found in module bundle")
            return
        }
        print("🔄 override bundle path:", path)
        objc_setAssociatedObject(Bundle.self, &overrideBundleKey, langBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Swizzled implementation
    @objc private func swizzled_localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        if let override = objc_getAssociatedObject(Bundle.self, &overrideBundleKey) as? Bundle {
            return override.swizzled_localizedString(
                forKey: key,
                value: value,
                table: tableName
            )
        }
        
        return swizzled_localizedString(
            forKey: key,
            value: value,
            table: tableName
        )
    }
    
    static var overrideBundle: Bundle {
        if let bundle = objc_getAssociatedObject(Bundle.self, &overrideBundleKey) as? Bundle {
            return bundle
        }
        
        if let raw = UserDefaults.standard.string(forKey: "LoggieLanguage"),
           let lang = Language(rawValue: raw),
           let path = Bundle.module.path(forResource: lang.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.self, &overrideBundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bundle
        }
        return .module
    }
}
