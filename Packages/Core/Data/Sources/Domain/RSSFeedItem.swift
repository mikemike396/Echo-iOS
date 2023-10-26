//
//  RSSFeedItem.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation
import SwiftData

@Model
final public class RSSFeedItem {
    public var title: String?
    @Attribute(.unique) public var link: String?
    public var publishedDate: Date?
    public var hasRead: Bool = false
    public var imageURL: URL?
    @Relationship(deleteRule: .noAction, inverse: \RSSFeed.items) public var feed: RSSFeed?

    public init() {}
}

// MARK: - Extensions

extension RSSFeedItem: Identifiable {
    public var id: String {
        (title ?? "") + (link ?? "")
    }
}
