//
//  RSSFeedResponseItem.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation

public struct RSSFeedResponseItem {
    public let title: String?
    public let link: String?
    public let description: String?

    public init(title: String?, link: String?, description: String?) {
        self.title = title
        self.link = link
        self.description = description
    }
}

// MARK: - Extensions

extension RSSFeedResponseItem: Identifiable {
    public var id: String {
        (title ?? "") + (description ?? "")
    }
}
