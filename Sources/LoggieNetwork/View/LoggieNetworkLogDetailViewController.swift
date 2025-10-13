//
//  LoggieNetworkLogDetailViewController.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/5/25.
//

import UIKit
import Foundation

class LoggieNetworkLogDetailViewController: UIViewController {
    private let debugLog: LoggieNetworkLog
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    init(debugLog: LoggieNetworkLog) {
        self.debugLog = debugLog
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 60, g: 60, b: 60)
        navigationController?.navigationBar.tintColor = .white
        
        setupScrollView()
        setupStackView(log: debugLog)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let bundle = Bundle.overrideBundle
        title = String(localized: "title.details", bundle: bundle)
    }
    
    private func setupScrollView() {
        // ScrollView configuration
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupStackView(log: LoggieNetworkLog) {
        // Timestamp
        let timestampText: String = {
            if let t = log.timestamp { return "\(t)" } else { return "Unable to retrieve timestamp." }
        }()
        let timestampLabel = makeTitleLabel(text: "Timestamp")
        stackView.addArrangedSubview(timestampLabel)
        let tsSep = makeSeparatorView(length: timestampLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(tsSep)
        let tsTextView = makeContentTextView(text: timestampText)
        stackView.addArrangedSubview(tsTextView)
        addCopyInteraction(to: timestampLabel, textProvider: { timestampText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Response Status Code (copy only the numeric code)
        let statusCodeLabel = makeTitleLabel(text: "Response Status Code : \(log.responseStatusCode)")
        stackView.addArrangedSubview(statusCodeLabel)
        let statusSep = makeSeparatorView(length: statusCodeLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(statusSep)
        addCopyInteraction(to: statusCodeLabel, textProvider: { "\(log.responseStatusCode)" })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Duration
        let durationText = "\(Int(log.duration))ms"
        let durationLabel = makeTitleLabel(text: "Duration")
        stackView.addArrangedSubview(durationLabel)
        let durSep = makeSeparatorView(length: durationLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(durSep)
        let durationTextView = makeContentTextView(text: durationText)
        stackView.addArrangedSubview(durationTextView)
        addCopyInteraction(to: durationLabel, textProvider: { durationText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Request URL
        let requestURLText = log.requestURL ?? "NO REQUEST URL"
        let requestURLLabel = makeTitleLabel(text: "Request URL")
        stackView.addArrangedSubview(requestURLLabel)
        let urlSep = makeSeparatorView(length: requestURLLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(urlSep)
        let requestURLTextView = makeContentTextView(text: requestURLText)
        stackView.addArrangedSubview(requestURLTextView)
        addCopyInteraction(to: requestURLLabel, textProvider: { requestURLText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // End Point
        let endPointText = log.endPoint ?? "NO END POINT"
        let endPointLabel = makeTitleLabel(text: "End Point")
        stackView.addArrangedSubview(endPointLabel)
        let endSep = makeSeparatorView(length: endPointLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(endSep)
        let endPointTextView = makeContentTextView(text: endPointText)
        stackView.addArrangedSubview(endPointTextView)
        addCopyInteraction(to: endPointLabel, textProvider: { endPointText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Method
        let methodText = log.method ?? "NO METHOD"
        let methodLabel = makeTitleLabel(text: "Method")
        stackView.addArrangedSubview(methodLabel)
        let methodSep = makeSeparatorView(length: methodLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(methodSep)
        let methodTextView = makeContentTextView(text: methodText)
        stackView.addArrangedSubview(methodTextView)
        addCopyInteraction(to: methodLabel, textProvider: { methodText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Request Body
        let requestBodyText = log.requestBody
        let requestBodyLabel = makeTitleLabel(text: "Request Body")
        stackView.addArrangedSubview(requestBodyLabel)
        let bodySep = makeSeparatorView(length: requestBodyLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(bodySep)
        let requestBodyTextView = makeContentTextView(text: requestBodyText)
        stackView.addArrangedSubview(requestBodyTextView)
        addCopyInteraction(to: requestBodyLabel, textProvider: { requestBodyText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        // Response Data
        let responseDataText = log.responseData
        let responseDataLabel = makeTitleLabel(text: "Response Data")
        stackView.addArrangedSubview(responseDataLabel)
        let dataSep = makeSeparatorView(length: responseDataLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(dataSep)
        let responseDataTextView = makeContentTextView(text: responseDataText)
        stackView.addArrangedSubview(responseDataTextView)
        addCopyInteraction(to: responseDataLabel, textProvider: { responseDataText })
        stackView.addArrangedSubview(makeSpaceView(height: 10))
    }
}

extension LoggieNetworkLogDetailViewController {
    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = text
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeContentLabel(text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        label.text = text
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func makeContentTextView(text: String) -> UITextView {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.text = text
        
        let maxWidth = view.bounds.width - 32
        let fittingSize = tv.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let contentHeight = fittingSize.height
        tv.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        
        return tv
    }
    
    private func makeSeparatorView(length: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 8),
            lineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            lineView.topAnchor.constraint(equalTo: containerView.topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2),
            lineView.widthAnchor.constraint(equalToConstant: length + 4)
        ])
        
        return containerView
    }
    
    private func makeSpaceView(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: height)
        ])
        return spacer
    }
}

// MARK: - Copy Interaction
private final class CopyTapGestureRecognizer: UITapGestureRecognizer {
    let textProvider: () -> String
    init(textProvider: @escaping () -> String, target: Any?, action: Selector?) {
        self.textProvider = textProvider
        super.init(target: target, action: action)
        numberOfTapsRequired = 1
    }
}

extension LoggieNetworkLogDetailViewController {
    private func addCopyInteraction(to view: UIView, textProvider: @escaping () -> String) {
        view.isUserInteractionEnabled = true
        let tap = CopyTapGestureRecognizer(textProvider: textProvider, target: self, action: #selector(handleCopyTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleCopyTap(_ sender: CopyTapGestureRecognizer) {
        let text = sender.textProvider()
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let bundle = Bundle.overrideBundle
        showCopyToast(message: String(localized: "message.copied", bundle: bundle))
    }
    
    private func showCopyToast(message: String) {
        let toast = UILabel()
        toast.text = " \(message) "
        toast.textColor = .white
        toast.font = .systemFont(ofSize: 13, weight: .medium)
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.layer.cornerRadius = 12
        toast.layer.masksToBounds = true
        toast.alpha = 0
        toast.textAlignment = .center
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.heightAnchor.constraint(equalToConstant: 34),
            toast.widthAnchor.constraint(equalToConstant: toast.intrinsicContentSize.width + 16),
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        UIView.animate(withDuration: 0.18, animations: { toast.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.22, delay: 0.8, options: .curveEaseInOut, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
