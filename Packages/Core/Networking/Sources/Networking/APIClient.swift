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
        return try await withCheckedThrowingContinuation { continuation in
            parser.parseAsync { result in
                switch result {
                case .success(let feed):
                    continuation.resume(returning: feed.rssFeed)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
