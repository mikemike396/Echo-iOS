//
//  APIInterface.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation

public protocol APIInterface {
    func getRSSFeed(for url: URL?) async throws -> RSSFeedResponse?
    func getSearchIndex() async throws -> [SearchIndexResponse]?
}
