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

public actor FeedRepository: ModelActor {
    public let modelContainer: ModelContainer
    public let modelExecutor: any ModelExecutor
    private let api: APIInterface

    public init(container: ModelContainer = EchoModelContainer.shared.modelContainer, api: APIInterface = APIClient()) {
        self.modelContainer = container
        let context = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.api = api
    }

    public func syncFeed() async throws {
        let fetchRSSFeeds = FetchDescriptor<RSSFeed>()
        let rssFeeds = try? modelExecutor.modelContext.fetch(fetchRSSFeeds)

        for rssFeed in rssFeeds ?? [] {
            let feed = try await api.getRSSFeed(for: URL(string: rssFeed.link ?? ""))

            var feedImageString = ""
            if let imageLink = feed?.image?.url {
                feedImageString = imageLink
            } else {
                feedImageString = "\(feed?.link ?? "")/favicon.ico"
            }
            let feedImageURL = URL(string: feedImageString)

            rssFeed.title = feed?.title
            rssFeed.imageURL = feedImageURL

            let items = feed?.items?.compactMap { item in
                let newFeedItem = rssFeed.items.first(where: { $0.link == item.link }) ?? RSSFeedItem()
                newFeedItem.title = item.title
                newFeedItem.publishedDate = item.pubDate
                newFeedItem.link = item.link
                newFeedItem.imageURL = try? getImageURLForDescriptionHTML(item.description)
                return newFeedItem
            }

            rssFeed.items = items ?? []

            modelExecutor.modelContext.insert(rssFeed)
        }
    }

    public func setItemRead(link: String) throws {
        var descriptor = FetchDescriptor<RSSFeedItem>()
        descriptor.predicate = #Predicate<RSSFeedItem> { item in
            item.link == link
        }
        let result = (try? modelExecutor.modelContext.fetch(descriptor))?.first
        result?.hasRead = true
    }

    public func addFeed(link: String?) throws {
        let predicate = #Predicate<RSSFeed> { $0.link == link }
        let fetchFeed = FetchDescriptor(predicate: predicate)
        let newFeed = (try? modelExecutor.modelContext.fetch(fetchFeed))?.first ?? RSSFeed()

        newFeed.link = link
        newFeed.addDate = .now
        newFeed.title = link

        modelExecutor.modelContext.insert(newFeed)
    }

    public func deleteFeed(link: String?) throws {
        var descriptor = FetchDescriptor<RSSFeed>()
        descriptor.predicate = #Predicate<RSSFeed> { item in
            item.link == link
        }
        if let result = (try? modelExecutor.modelContext.fetch(descriptor))?.first {
            modelExecutor.modelContext.delete(result)
        }
    }

    private func getImageURLForDescriptionHTML(_ html: String?) throws -> URL? {
        guard let html else { return nil }

        let document = try SwiftSoup.parse(html)
        let srcs = try document.select("img[src]")
        let array = srcs.array().compactMap { try? $0.attr("src").description }
        return URL(string: array.first ?? "")
    }
}
