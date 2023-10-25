//
//  APIClient.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import FeedKit
import Foundation

public class APIClient: APIInterface {
    public init() {}

    public func getRSSFeed(for url: URL?) async throws -> RSSFeed? {
        guard let url else { throw APIError.invalidURL }

        let parser = FeedParser(URL: url)
        let result = parser.parse()

        switch result {
        case .success(let feed):
            return feed.rssFeed
        case .failure(let error):
            throw error
        }
    }
}
