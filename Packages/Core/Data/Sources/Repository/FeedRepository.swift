//
//  FeedRepository.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation
import Networking
import SwiftData
import SwiftSoup

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

        var feedImageString = ""
        if let imageLink = feed?.image?.url {
            feedImageString = imageLink
        } else {
            feedImageString = "\(feed?.link ?? "")/favicon.ico"
        }
        let feedImageURL = URL(string: feedImageString)

        let items = feed?.items?.compactMap { item in
            let newFeedItem = newFeed.items.first(where: { $0.link == item.link }) ?? RSSFeedItem()
            newFeedItem.title = item.title
            newFeedItem.publishedDate = item.pubDate
            newFeedItem.link = item.link
            newFeedItem.imageURL = try? findImageURLForDescriptionHTML(item.description)
            return newFeedItem
        }

        newFeed.title = feed?.title
        newFeed.link = url?.absoluteString
        newFeed.imageURL = feedImageURL
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

    private func findImageURLForDescriptionHTML(_ html: String?) throws -> URL? {
        guard let html else { return nil }

        let document = try SwiftSoup.parse(html)
        let srcs = try document.select("img[src]")
        let array = srcs.array().compactMap { try? $0.attr("src").description }
        return URL(string: array.first ?? "")
    }
}
