//
//  RSSFeedItemResponse.swift
//
//
//  Created by Michael Kushinski on 11/1/23.
//

import Foundation

public struct RSSFeedItemResponse {
    public let title: String?
    public let link: String?
    public let publishedDate: Date?
    public let mediaContentsURL: String?
    public let enclosureURL: String?
    public let description: String?
}
