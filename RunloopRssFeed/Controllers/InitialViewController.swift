//
//  ViewController.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    var timer: Timer?
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy HH:mm:ss"
        return df
    }()
    
    @IBOutlet weak var timeDateLabel: UILabel!
    @IBOutlet weak var feedTypeLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = {
        var ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegation()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let current = Date()
        timeDateLabel.text = formatter.string(from: current)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getTimeDate), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // setting up the delegate to transfer data between view controllers
    
    func setupDelegation() {
        if let controllers = self.tabBarController?.viewControllers {
            if let navCon = controllers[1] as? UINavigationController {
                if let rssVC = navCon.viewControllers.first as? RSSViewController {
                    rssVC.delegate = self
                }
            }
        }
    }
    
    func setupUI() {
        let barItem = UIBarButtonItem(customView: self.activityIndicator)
        self.navigationItem.rightBarButtonItem = barItem
    }
    
    @objc func getTimeDate() {
        let current = Date()
        timeDateLabel.text = formatter.string(from: current)
    }

}

extension InitialViewController: RSSViewControllerDelegate {
    
    // delegate methods to stay updated on changes in RSS
    
    func startParsing() {
        self.activityIndicator.startAnimating()
    }
    
    func stopParsing() {
        self.activityIndicator.stopAnimating()
    }
    
    func changeFeed(_ feedNumber: Int) {
        if let feedType = FeedType(rawValue: feedNumber) {
            switch feedType {
            case .business:
                self.feedTypeLabel.text = "Business"
            default:
                self.feedTypeLabel.text = "Entertainment/Environment"
            }
        }
    }
    
    
}

