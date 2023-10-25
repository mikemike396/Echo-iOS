//
//  FeedRepository.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation
import Networking
import SwiftData

public class FeedRepository {
    private let context: ModelContext
    private let api: APIInterface

    public init(container: ModelContainer = EchoModelContainer.shared.modelContainer, api: APIInterface = APIClient()) {
        self.context = ModelContext(container)
        self.api = api
    }

    public func fetchFeed(url: URL?) async throws {
        let feed = try await api.getRSSFeed(for: url)

        var imageString = ""
        if let imageLink = feed?.image?.url {
            imageString = imageLink
        } else {
            imageString = "\(feed?.link ?? "")/favicon.ico"
        }
        let imageURL = URL(string: imageString)
        let items = feed?.items?.compactMap { item in
            RSSFeedItem(title: item.title, link: item.link, publishedDate: item.pubDate)
        } ?? []

        let newFeed = RSSFeed(title: feed?.title, link: feed?.link, imageURL: imageURL)
        newFeed.items = items
        
        context.insert(newFeed)
    }
}
