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

    public func syncFeed(url: URL?) async throws {
        let feed = try await api.getRSSFeed(for: url)

        let predicate = #Predicate<RSSFeed> { $0.link == url?.absoluteString }
        let fetchFeed = FetchDescriptor(predicate: predicate)
        let newFeed = (try? context.fetch(fetchFeed))?.first ?? RSSFeed()

        var imageString = ""
        if let imageLink = feed?.image?.url {
            imageString = imageLink
        } else {
            imageString = "\(feed?.link ?? "")/favicon.ico"
        }
        let imageURL = URL(string: imageString)

        let items = feed?.items?.compactMap { item in
            let newFeedItem = newFeed.items.first(where: { $0.link == item.link }) ?? RSSFeedItem()
            newFeedItem.title = item.title
            newFeedItem.publishedDate = item.pubDate
            return newFeedItem
        }

        newFeed.title = feed?.title
        newFeed.link = url?.absoluteString
        newFeed.imageURL = imageURL
        newFeed.items = items ?? []

        context.insert(newFeed)
    }

    public func setItemRead(link: String) throws {
        var descriptor = FetchDescriptor<RSSFeedItem>()
        descriptor.predicate = #Predicate<RSSFeedItem> { item in
            item.link == link
        }
        let result = (try? context.fetch(descriptor))?.first
        result?.hasRead = true
    }
}
