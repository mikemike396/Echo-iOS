
import FeedKit
import Foundation
import Models

public struct APIClient {
    public static func getRSSFeed(for url: URL?) async throws -> RSSFeedResponse? {
        guard let url else { throw APIError.invalidURL}

        let parser = FeedParser(URL: url)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            return RSSFeedResponse(items: feed.rssFeed?.items?.compactMap { RSSFeedResponseItem(title: $0.title, link: $0.link, description: $0.description) } ?? [])
        case .failure(let error):
            throw error
        }
    }
}
