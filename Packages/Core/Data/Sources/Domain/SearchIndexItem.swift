//
//  SearchIndexItem.swift
//
//
//  Created by Michael Kushinski on 11/1/23.
//

import Foundation
import SwiftData

@Model
final public class SearchIndexItem {
    @Attribute(.unique) public let id: String
    public let title: String
    public let url: URL

    public init(id: String, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
}
