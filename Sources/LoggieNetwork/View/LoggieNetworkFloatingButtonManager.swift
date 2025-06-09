//
//  LoggieNetworkFloatingButtonManager.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/22/25.
//
import SwiftUI
import UIKit
import Loggie

@MainActor
final internal class LoggieNetworkFloatingButtonManager {
    static let shared = LoggieNetworkFloatingButtonManager()
    private var logWindow: UIWindow?
    private var logButton: UIButton?
    private var floatingWindow: UIWindow?
    private var modalPresentationWindow: UIWindow?
    
    private init() {}
    
    func show() {
        showButton()
    }
    
    func hide() {
        hideButton()
    }
    
    internal func showButton(animated: Bool = true) {
        if let btn = logButton {
            btn.isHidden = false
            animate(btn: btn, appear: true, animated: animated)
            return
        }
        
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        
        let newWindow = PassThroughWindow(windowScene: windowScene)
        newWindow.windowLevel = UIWindow.Level.alert + 1
        newWindow.backgroundColor = .clear
        newWindow.isHidden = false
        
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        newWindow.rootViewController = vc
        
        let btn = UIButton(type: .system)
        btn.setTitle("Network Log", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.alpha = 0
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        vc.view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            btn.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            btn.widthAnchor.constraint(equalToConstant: 200),
            btn.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        logButton = btn
        logWindow = newWindow
        animate(btn: btn, appear: true, animated: animated)
    }
    
    internal func hideButton(animated: Bool = true) {
        guard let btn = logButton else { return }
        animate(btn: btn, appear: false, animated: animated) {
            btn.isHidden = true
        }
    }
    
    private func animate(btn: UIButton, appear: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        let targetAlpha: CGFloat = appear ? 1 : 0
        if animated {
            if appear { btn.alpha = 0 }
            UIView.animate(withDuration: 0.25, animations: {
                btn.alpha = targetAlpha
            }, completion: { _ in completion?() })
        } else {
            btn.alpha = targetAlpha
            completion?()
        }
    }
    
    @objc private func buttonTapped() {
        let vc = LoggieNetworkLogListViewController().toNavigationController()
        vc.modalPresentationStyle = .overFullScreen
        vc.overrideUserInterfaceStyle = .dark
        if let topVC = UIApplication.topViewController() {
            topVC.present(vc, animated: true)
            self.hideButton()
        }
    }
    
    private func animateAlpha(to alpha: CGFloat, animated: Bool) {
        guard let button = self.logButton else { return }
        if animated {
            UIView.animate(withDuration: 0.25) {
                button.alpha = alpha
            }
        } else {
            button.alpha = alpha
        }
    }
}

class PassThroughWindow: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let rootVC = rootViewController else { return false }
        let convertedPoint = rootVC.view.convert(point, from: self)

        for subview in rootVC.view.subviews {
            if
                !subview.isHidden,
                subview.alpha > 0,
                subview.isUserInteractionEnabled,
                subview.point(inside: subview.convert(convertedPoint, from: rootVC.view), with: event)
            {
                return true
            }
        }
        return false
    }
}

extension UIViewController {
    func toNavigationController() -> UINavigationController {
        let navVC = UINavigationController.init(rootViewController: self)
        navVC.navigationBar.isHidden = false
        return navVC
    }
}
