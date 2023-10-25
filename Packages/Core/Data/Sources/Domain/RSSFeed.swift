//
//  RSSFeed.swift
//
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation
import SwiftData

@Model
final public class RSSFeed {
    public var title: String?
    @Attribute(.unique) public var link: String?
    public var imageURL: URL?
    @Relationship(deleteRule: .cascade) public var items: [RSSFeedItem] = []

    public init(title: String?, link: String?, imageURL: URL?) {
        self.title = title
        self.link = link
        self.imageURL = imageURL
    }
}
