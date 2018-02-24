//
//  RequestBuilder.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation
import FeedKit

// small structure to store every RSS feed in one place

struct RSSDataSource {
    
    var businessFeed: RSSFeed? = nil
    
    var entertainmentFeed: RSSFeed? = nil
    
    var environmentFeed: RSSFeed? = nil
    
}
