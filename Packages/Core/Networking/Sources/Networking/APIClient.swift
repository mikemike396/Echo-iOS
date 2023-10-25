
import FeedKit
import Foundation
import Models

public class APIClient: APIInterface {
    public init() {}

    public func getRSSFeed(for url: URL?) async throws -> RSSFeedResponse? {
        guard let url else { throw APIError.invalidURL }

        let parser = FeedParser(URL: url)
        let result = parser.parse()

        switch result {
        case .success(let feed):
            let imageURL = URL(string: feed.rssFeed?.image?.url ?? "")
            let items = feed.rssFeed?.items?.compactMap { item in
                RSSFeedResponseItem(title: item.title, link: item.link, description: item.description, publishedDate: item.pubDate)
            } ?? []

            return RSSFeedResponse(imageURL: imageURL, items: items)
        case .failure(let error):
            throw error
        }
    }
}
