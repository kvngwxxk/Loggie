//
//  LoggieNetworkTracker.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//

import Foundation
import SwiftUI
import UIKit
import Loggie
import Alamofire

public final class LoggieNetworkTracker {
    public let interceptor: RequestInterceptor & EventMonitor = LoggieNetworkInterceptor()
    public init() {}
    
    @MainActor
    public func show(from presentingVC: UIViewController? = nil) {
        LoggieNetworkFloatingButtonManager.shared.showButton()
    }
    
    @MainActor
    public func hide(from presentingVC: UIViewController? = nil) {
        LoggieNetworkFloatingButtonManager.shared.hideButton()
    }
}

extension UIApplication {
    public static func sharedSceneKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow
    }
    
    class func mainWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.windowLevel == UIWindow.Level.normal })
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.mainWindow()?.rootViewController) -> UIViewController? {
        if let nav = controller as? UINavigationController {
            return topViewController(controller: nav.visibleViewController)
        }
        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(controller: selected)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
