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

/// A tracker object responsible for managing network logging UI and interceptors.
public final class LoggieNetworkTracker {
    /// Alamofire interceptor that captures and monitors network traffic.
    public let interceptor: RequestInterceptor & EventMonitor = LoggieNetworkInterceptor()

    /// Creates a new instance of the network tracker.
    public init() {}

    /// Displays the floating tracker button.
    /// - Parameter presentingVC: Optional view controller context.
    @MainActor
    public func show(from presentingVC: UIViewController? = nil) {
        LoggieNetworkFloatingButtonManager.shared.showButton()
    }

    /// Hides the floating tracker button.
    /// - Parameter presentingVC: Optional view controller context.
    @MainActor
    public func hide(from presentingVC: UIViewController? = nil) {
        LoggieNetworkFloatingButtonManager.shared.hideButton()
    }
}

extension UIApplication {
    /// Returns the current key window of the active foreground scene.
    public static func sharedSceneKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow
    }

    /// Returns the main window at normal level.
    class func mainWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.windowLevel == UIWindow.Level.normal })
    }

    /// Recursively finds the topmost presented view controller.
    /// - Parameter controller: Starting point controller. Defaults to root.
    /// - Returns: The top-most view controller if available.
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
