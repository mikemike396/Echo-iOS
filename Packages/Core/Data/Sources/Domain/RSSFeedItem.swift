//
//  RSSFeedItem.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation
import SwiftData

@Model
final public class RSSFeedItem {
    public let title: String?
    @Attribute(.unique) public let link: String?
    public let publishedDate: Date?
    @Relationship(deleteRule: .noAction, inverse: \RSSFeed.items) public var feed: RSSFeed?

    public init(title: String?, link: String?, publishedDate: Date?) {
        self.title = title
        self.link = link
        self.publishedDate = publishedDate
    }
}

// MARK: - Extensions

extension RSSFeedItem: Identifiable {
    public var id: String {
        (title ?? "") + (link ?? "")
    }
}
