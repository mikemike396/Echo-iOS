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
    public let title: String
    @Attribute(.unique) public let url: URL

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}
