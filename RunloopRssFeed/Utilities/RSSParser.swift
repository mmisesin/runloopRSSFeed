//
//  RSSParser.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation
import FeedKit

class RSSParser {
    
    var parser: FeedParser?
    
    let businessURL = URL(string: AppConstants.businessFeedURL)!
    let entertainmentURL = URL(string: AppConstants.entertainmentFeedURL)!
    let environmentURL = URL(string: AppConstants.environmentFeedURL)!
    
    func parse(_ feed: FeedType, callback: @escaping (RSSFeed?, Error?) -> Void) {
        switch feed {
        case .business:
            self.parser = FeedParser(URL: businessURL)
        case .entertainment:
            self.parser = FeedParser(URL: entertainmentURL)
        case .environment:
            self.parser = FeedParser(URL: environmentURL)
        }
        guard self.parser != nil else {
            callback(nil, NSError(domain: "Nil parser", code: 1, userInfo: nil))
            return
        }
        
        parser!.parseAsync(result: { (result) in
            switch result {
            case let .rss(feed):
                callback(feed, nil)
            case let .failure(error):
                callback(nil, error)
            default: break
            }
        })
    }
}
