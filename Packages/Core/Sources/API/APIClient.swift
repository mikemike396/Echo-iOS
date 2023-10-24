
import FeedKit
import Foundation

public struct APIClient {
    public static func getRSSFeed(for url: URL) async throws -> RSSFeed? {
        let parser = FeedParser(URL: url)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            return feed.rssFeed
        case .failure(let error):
            print(error)
        }
        return nil
    }
}
