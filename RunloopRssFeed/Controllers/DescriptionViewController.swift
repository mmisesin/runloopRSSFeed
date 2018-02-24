//
//  DescriptionViewController.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import FeedKit

class DescriptionViewController: UIViewController {

    var feedItem: RSSFeedItem?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    private func fetchData() {
        if let item = self.feedItem {
            self.titleLabel.text = item.title ?? "Unknown"
            if let description = item.description {
                self.descriptionView.text = description.components(separatedBy: "<")[0]
            }
        }
    }

}
