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
    public let link: String

    public init(id: String, title: String, link: String) {
        self.id = id
        self.title = title
        self.link = link
    }
}
