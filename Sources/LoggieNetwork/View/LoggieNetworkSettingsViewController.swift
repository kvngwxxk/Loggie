//
//  LoggieNetworkSettingsViewController.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/12/25.
//
import Foundation
import UIKit
import Loggie

internal enum Language: String {
    case english = "en"
    case korean = "ko"
    
    mutating func toggle() {
        self = (self == .english) ? .korean : .english
    }
}

class LoggieNetworkSettingsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private var currentLanguage: Language = .english
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 60, g: 60, b: 60)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupScrollView()
        setupStackView()
        
        Bundle.enableDynamicLocalization()
        
        if let lang = UserDefaults.standard.string(forKey: "LoggieLanguage"), let langugage = Language(rawValue: lang) {
            currentLanguage = langugage
        }
        
        Bundle.setOverrideLanguage(currentLanguage)
        reloadAllSections()
    }
    
    private func setupScrollView() {
        // ScrollView configuration
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        scrollView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            view.heightAnchor.constraint(equalToConstant: 1000).withPriority(UILayoutPriority(250))
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        let bundle = Bundle.overrideBundle
        
        title = String(localized: "title.settings", bundle: bundle)
        
        let firstSection = makeSettingsView(
            title: String(localized: "content.title.language", bundle: bundle),
            text:  String(localized: "content.language",      bundle: bundle)
        )
        firstSection.tag = 1
        stackView.addArrangedSubview(firstSection)
        stackView.addArrangedSubview(makeSeparatorView())
        
        firstSection.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapFirstSection(_:)))
        )
        
        let version = LoggieVersion.short
        let secondSection = makeSettingsView(
            title: String(localized: "content.title.version", bundle: bundle),
            text:  version
        )
        stackView.addArrangedSubview(secondSection)
        stackView.addArrangedSubview(makeSeparatorView())
        
        let thirdSection = makeSettingsView(
            title: String(localized: "content.title.clearData", bundle: bundle),
            text:  String(localized: "content.clearAllLogs", bundle: bundle)
        )
        thirdSection.tag = 3
        stackView.addArrangedSubview(thirdSection)
        stackView.addArrangedSubview(makeSeparatorView())
        
        thirdSection.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapThirdSection(_:)))
        )
    }
    
    @objc private func didTapFirstSection(_ gr: UITapGestureRecognizer) {
        guard gr.view?.tag == 1 else { return }
        
        currentLanguage.toggle()

        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "LoggieLanguage")
        Bundle.setOverrideLanguage(currentLanguage)
        
        reloadAllSections()
    }
    
    @objc private func didTapThirdSection(_ gr: UITapGestureRecognizer) {
        guard gr.view?.tag == 3 else { return }
        let bundle = Bundle.overrideBundle
        let titleText = String(localized: "message.title.notice", bundle: bundle)
        let contentText = String(localized: "message.clearAllLogs", bundle: bundle)
        
        let vc = UIAlertController(title: titleText, message: contentText, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            CoreDataManager.shared.deleteAllData() { result in
                switch result {
                case .success:
                    ()
                case .failure(let error):
                    ()
                }
                self.navigationController?.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        LoggieNetworkFloatingButtonManager.shared.showButton()
                    }
                }
            }
        }
        let closeAction = UIAlertAction(title: "Cancel", style: .default)
        
        vc.addAction(closeAction)
        vc.addAction(confirmAction)
        
        present(vc, animated: false)
    }
    
    private func reloadAllSections() {
        stackView.arrangedSubviews.forEach { subview in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        setupStackView()
    }
}

extension LoggieNetworkSettingsViewController {
    private func makeSettingsView(title: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.text = title
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .systemFont(ofSize: 14, weight: .regular)
        textLabel.text = text
        
        containerView.addSubview(textLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func makeSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return separatorView
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
