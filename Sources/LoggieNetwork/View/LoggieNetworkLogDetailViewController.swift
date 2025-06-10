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
        navigationItem.title = ""
        setupScrollView()
        setupStackView(log: debugLog)
    }

    private func setupScrollView() {
        // ScrollView configuration
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.indicatorStyle = .white
        scrollView.backgroundColor = .clear
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

    private func setupStackView(log: LoggieNetworkLog, isExample: Bool = false) {
        let timestampLabel = makeTitleLabel(text: "Timestamp")
        stackView.addArrangedSubview(timestampLabel)
        let tsSep = makeSeparatorView(length: timestampLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(tsSep)
        if let timestamp = log.timestamp {
            let textView = makeContentTextView(text: "\(timestamp)")
            stackView.addArrangedSubview(textView)
        } else {
            let textView = makeContentTextView(text: "Unable to retrieve timestamp.")
            stackView.addArrangedSubview(textView)
        }
        stackView.addArrangedSubview(makeSpaceView(height: 10))
        
        let responseStatusCodeLabel = makeTitleLabel(text: "Response Status Code : \(log.responseStatusCode)")
        stackView.addArrangedSubview(responseStatusCodeLabel)
        let statusSep = makeSeparatorView(length: responseStatusCodeLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(statusSep)
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let durationLabel = makeTitleLabel(text: "Duration")
        stackView.addArrangedSubview(durationLabel)
        let durSep = makeSeparatorView(length: durationLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(durSep)
        stackView.addArrangedSubview(makeContentTextView(text: "\(Int(log.duration))ms"))
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let requestURLLabel = makeTitleLabel(text: "Request URL")
        stackView.addArrangedSubview(requestURLLabel)
        let urlSep = makeSeparatorView(length: requestURLLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(urlSep)
        stackView.addArrangedSubview(makeContentTextView(text: log.requestURL ?? "NO REQUEST URL"))
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let endPointLabel = makeTitleLabel(text: "End Point")
        stackView.addArrangedSubview(endPointLabel)
        let endSep = makeSeparatorView(length: endPointLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(endSep)
        stackView.addArrangedSubview(makeContentTextView(text: log.endPoint ?? "NO END POINT"))
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let methodLabel = makeTitleLabel(text: "Method")
        stackView.addArrangedSubview(methodLabel)
        let methodSep = makeSeparatorView(length: methodLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(methodSep)
        stackView.addArrangedSubview(makeContentTextView(text: log.method ?? "NO METHOD"))
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let requestBodyLabel = makeTitleLabel(text: "Request Body")
        stackView.addArrangedSubview(requestBodyLabel)
        let bodySep = makeSeparatorView(length: requestBodyLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(bodySep)
        stackView.addArrangedSubview(makeContentTextView(text: log.requestBody))
        stackView.addArrangedSubview(makeSpaceView(height: 10))

        let responseDataLabel = makeTitleLabel(text: "Response Data")
        stackView.addArrangedSubview(responseDataLabel)
        let dataSep = makeSeparatorView(length: responseDataLabel.intrinsicContentSize.width)
        stackView.addArrangedSubview(dataSep)
        stackView.addArrangedSubview(makeContentTextView(text: log.responseData))
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
