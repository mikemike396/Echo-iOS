//
//  RSSFeedResponse.swift
//
//
//  Created by Michael Kushinski on 11/1/23.
//

import FeedKit
import Foundation

public struct RSSFeedResponse {
    public let title: String?
    public let link: String?
    public let imageURL: String?
    public let items: [RSSFeedItemResponse]?

    init(rssFeed: RSSFeed?) {
        title = rssFeed?.title
        link = rssFeed?.link
        imageURL = rssFeed?.image?.url
        items = rssFeed?.items?.map { RSSFeedItemResponse(title: $0.title, link: $0.link, publishedDate: $0.pubDate, mediaContentsURL: $0.media?.mediaContents?.first?.attributes?.url, enclosureURL: $0.enclosure?.attributes?.url, description: $0.description )}
    }
}
