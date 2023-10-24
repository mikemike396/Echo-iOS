//
//  RSSFeedResponse.swift
//
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation

public struct RSSFeedResponse {
    public let items: [RSSFeedResponseItem]

    public init(items: [RSSFeedResponseItem]) {
        self.items = items
    }
}
