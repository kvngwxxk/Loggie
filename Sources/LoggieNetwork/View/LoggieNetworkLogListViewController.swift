//
//  LoggieNetworkLogListViewController.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/5/25.
//

import CoreData
import Foundation
import UIKit

class LoggieNetworkLogListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var logs: [LoggieNetworkLog] = []
    let backgroundColor: UIColor = .rgb(r: 60, g: 60, b: 60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        
        setupUI()
        fetchLogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Network Logs"
    }
    
    private func setupUI() {
        let gearImage = UIImage(systemName: "gearshape.fill")
        let settingsItem = UIBarButtonItem(
            image: gearImage,
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        settingsItem.tintColor = .white
        navigationItem.leftBarButtonItem = settingsItem

        let xImage = UIImage(systemName: "xmark")
        let xItem = UIBarButtonItem(
            image: xImage,
            style: .plain,
            target: self,
            action: #selector(didTapCloseButton)
        )
        xItem.tintColor = .white
        navigationItem.rightBarButtonItem = xItem

        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.backgroundColor = .clear
        tableView.register(LoggieNetworkLogTableViewCell.self, forCellReuseIdentifier: LoggieNetworkLogTableViewCell.reusableIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    
    private func fetchLogs() {
        
        let t0 = DispatchTime.now()
        
        let fetchStart = DispatchTime.now()
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<LoggieNetworkLog> = LoggieNetworkLog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetch = try context.fetch(request)
            self.logs = fetch
            self.tableView.reloadData()
            
        } catch {
            
            self.logs = []
            self.tableView.reloadData()
        }
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            LoggieNetworkFloatingButtonManager.shared.showButton()
        }
    }
    
    @objc func didTapSettingsButton() {
        
    }
    
    @objc func didTapClearButton() {
        print("did tap clear")
        let vc = UIAlertController(title: "Notice", message: "Do you want to delete all logs?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            CoreDataManager.shared.deleteAllData() { result in
                switch result {
                case .success:
                    ()
                case .failure(let error):
                    ()
                }
                
                self.fetchLogs()
                self.didTapCloseButton()
            }
        }
        let closeAction = UIAlertAction(title: "Cancel", style: .default)
        
        vc.addAction(closeAction)
        vc.addAction(confirmAction)
        
        present(vc, animated: false)
    }
}

extension LoggieNetworkLogListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoggieNetworkLogTableViewCell.reusableIdentifier, for: indexPath) as? LoggieNetworkLogTableViewCell else {
            return UITableViewCell()
        }
        
        let log = logs[indexPath.row]
        cell.configure(with: log)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = logs[indexPath.row]
        let vc = LoggieNetworkLogDetailViewController(debugLog: log)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIColor {
    static func rgb(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
