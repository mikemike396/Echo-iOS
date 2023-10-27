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
    public var addDate: Date?
    @Relationship(deleteRule: .cascade) public var items: [RSSFeedItem] = []

    public init() {}
}
