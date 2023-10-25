//
//  RSSFeedResponse.swift
//
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation

public struct RSSFeedResponse {
    public let imageURL: URL?
    public let items: [RSSFeedResponseItem]

    public init(imageURL: URL?, items: [RSSFeedResponseItem]) {
        self.imageURL = imageURL
        self.items = items
    }
}
