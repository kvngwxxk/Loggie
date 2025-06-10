//
//  LoggieNetworkLogTableViewCell.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/5/25.
//

import UIKit

class LoggieNetworkLogTableViewCell: UITableViewCell {
    
    static var reusableIdentifier: String = "LoggieNetworkLogTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(urlLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            urlLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with log: LoggieNetworkLog, isExample: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = log.timestamp.flatMap { formatter.string(from: $0) } ?? "N/A"
        let method = log.method ?? "N/A"
        titleLabel.text = "\(dateStr) / \(method.uppercased())"
        
        urlLabel.text = log.requestURL ?? "No URL"
    }
}







