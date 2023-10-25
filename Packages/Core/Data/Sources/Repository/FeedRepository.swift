//
//  FeedRepository.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation
import Networking

public class FeedRepository {
    private let api: APIInterface

    public init(api: APIInterface = APIClient()) {
        self.api = api
    }

    public func getFeed(url: URL?) async throws -> RSSFeedResponse {
        let feed = try await api.getRSSFeed(for: url)

        let imageURL = URL(string: feed?.image?.url ?? "")
        let items = feed?.items?.compactMap { item in
            RSSFeedResponseItem(title: item.title, link: item.link, description: item.description, publishedDate: item.pubDate)
        } ?? []

        return RSSFeedResponse(imageURL: imageURL, items: items)
    }
}
