//
//  RSSTableViewController.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import FeedKit

enum FeedType: Int {
    case business = 0
    case entertainment = 1
    case environment = 2
}

protocol RSSViewControllerDelegate {
    
    func changeFeed(_ feedNumber: Int)
    func startParsing()
    func stopParsing()
    
}

class RSSViewController: UIViewController {
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView = {
        var ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.hidesWhenStopped = true
        ai.startAnimating()
        return ai
    }()
    
    var timer = Timer()
    var delegate: RSSViewControllerDelegate?
    //var feedType: FeedType = .business
    
    var rssParser = RSSParser()
    var parsingCounter = 0 // counter to detect, if every feed was updated
    
    var dataSource = RSSDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.changeFeed(self.segmentedControl.selectedSegmentIndex)
        self.getData()
        self.runParseTimer()
        self.setupUI()
    }
    
    // Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.delegate?.changeFeed(sender.selectedSegmentIndex)
        self.tableView.reloadData()
    }
    
    func runParseTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)
    }
    
    @objc func getData() {
        
        // every 5 seconds we update each RSS feed by separately calling RSSParser.parse(_ feed: FeedType, callback: @escaping (RSSFeed?, Error?) -> Void)
        
        self.activityIndicator.startAnimating()
        self.delegate?.startParsing()
        self.rssParser.parse(.business) { (feed, error) in
            if error != nil {
                SimpleAlert.showAlert(alert: error!.localizedDescription, delegate: self)
            } else {
                self.dataSource.businessFeed = feed
                self.parsingCounter += 1
                DispatchQueue.main.async {
                    // if every feed is updated, we can hide the activityIndicator
                    if self.parsingCounter == 3 {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.stopParsing()
                        self.parsingCounter = 0
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        self.rssParser.parse(.entertainment) { (feed, error) in
            if error != nil {
                SimpleAlert.showAlert(alert: error!.localizedDescription, delegate: self)
            } else {
                self.dataSource.entertainmentFeed = feed
                self.parsingCounter += 1
                DispatchQueue.main.async {
                    if self.parsingCounter == 3 {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.stopParsing()
                        self.parsingCounter = 0
                    }
                    self.tableView.reloadData()
                }
            }
        }
        self.rssParser.parse(.environment) { (feed, error) in
            if error != nil {
                SimpleAlert.showAlert(alert: error!.localizedDescription, delegate: self)
            } else {
                self.dataSource.environmentFeed = feed
                self.parsingCounter += 1
                DispatchQueue.main.async {
                    if self.parsingCounter == 3 {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.stopParsing()
                        self.parsingCounter = 0
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupUI() {
        let barItem = UIBarButtonItem(customView: self.activityIndicator)
        self.navigationItem.rightBarButtonItem = barItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            guard let index = self.tableView.indexPath(for: cell) else {
                return
            }
            var item: RSSFeedItem?
            switch self.segmentedControl.selectedSegmentIndex {
            case 0:
                if let items = self.dataSource.businessFeed?.items {
                    item = items[index.row]
                } else {
                    return
                }
            case 1:
                switch index.section {
                case 0:
                    if let items = self.dataSource.entertainmentFeed?.items {
                        item = items[index.row]
                    } else {
                        return
                    }
                case 1:
                    if let items = self.dataSource.environmentFeed?.items {
                        item = items[index.row]
                    } else {
                        return
                    }
                default: return
                }
            default: return
            }
            if segue.identifier == "toDescription" {
                if let vc = segue.destination as? DescriptionViewController {
                    vc.feedItem = item
                }
            }
        }
    }

}

extension RSSViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.segmentedControl.selectedSegmentIndex {
        case 1:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.segmentedControl.selectedSegmentIndex {
        case 1:
            switch section {
            case 0:
                return "Entertainment"
            case 1:
                return "Environment"
            default: return nil
            }
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            switch section {
            case 0:
                if let entFeed = self.dataSource.entertainmentFeed {
                    if let entItems = entFeed.items {
                        return entItems.count
                    }
                }
            case 1:
                if let envFeed = self.dataSource.environmentFeed {
                    if let envItems = envFeed.items {
                        return envItems.count
                    }
                }
            default: return 0
            }
        default:
            if let busFeed = self.dataSource.businessFeed {
                if let busItems = busFeed.items {
                    return busItems.count
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rssCell", for: indexPath)
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            guard let feedItems = self.dataSource.businessFeed?.items else {
                return UITableViewCell()
            }
            cell.textLabel?.text = feedItems[indexPath.row].title
            if let pubDate = feedItems[indexPath.row].pubDate {
                cell.detailTextLabel?.text = self.formatter.string(from: pubDate)
            }
        case 1:
            switch indexPath.section {
            case 0:
                guard let feedItems = self.dataSource.entertainmentFeed?.items else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = feedItems[indexPath.row].title
                if let pubDate = feedItems[indexPath.row].pubDate {
                    cell.detailTextLabel?.text = self.formatter.string(from: pubDate)
                }
            case 1:
                guard let feedItems = self.dataSource.environmentFeed?.items else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = feedItems[indexPath.row].title
                if let pubDate = feedItems[indexPath.row].pubDate {
                    cell.detailTextLabel?.text = self.formatter.string(from: pubDate)
                }
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
        return cell
    }
    
}
