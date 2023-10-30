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
    
    /// Calls `getRSSFeed()` to fetch the latest for each `RSSFeed`
    public func syncFeed() async throws {
        let fetchRSSFeeds = FetchDescriptor<RSSFeed>()
        let rssFeeds = try? modelExecutor.modelContext.fetch(fetchRSSFeeds)

        for rssFeed in rssFeeds ?? [] {
            let feedResponse = try await api.getRSSFeed(for: URL(string: rssFeed.link ?? ""))

            rssFeed.title = feedResponse?.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            rssFeed.imageURL = getFeedIconURL(for: feedResponse?.image?.url, and: feedResponse?.link)

            let items = feedResponse?.items?.map { item in
                let newFeedItem = rssFeed.items.first(where: { $0.link == item.link }) ?? RSSFeedItem()
                newFeedItem.title = item.title?.trimmingCharacters(in: .whitespacesAndNewlines)
                newFeedItem.publishedDate = item.pubDate
                newFeedItem.link = item.link?.trimmingCharacters(in: .whitespacesAndNewlines)

                // Attempt to get image via MediaContents
                var mediaURL = item.media?.mediaContents?.first?.attributes?.url
                if mediaURL == nil {
                    // Attempt to get image via Enclosure
                    mediaURL = item.enclosure?.attributes?.url
                }
                if mediaURL == nil {
                    // Attempt to get image via Description
                    mediaURL = try? getFeedItemImageURLForDescriptionHTML(item.description)?.absoluteString
                }
                newFeedItem.imageURL = URL(string: mediaURL ?? "")
                return newFeedItem
            }

            rssFeed.items.append(contentsOf: items ?? [])

            modelExecutor.modelContext.insert(rssFeed)
        }
    }
    
    /// Sets the `hasRead` field to true for the provided `RSSFeed` link
    /// - Parameter link: String value for the `RSSFeed` link
    public func setItemRead(link: String) throws {
        var descriptor = FetchDescriptor<RSSFeedItem>()
        descriptor.predicate = #Predicate<RSSFeedItem> { item in
            item.link == link
        }
        let result = (try? modelExecutor.modelContext.fetch(descriptor))?.first
        result?.hasRead = true
    }

    /// Adds a new `RSSFeed` item for the provided link
    /// - Parameter link: String value for the `RSSFeed` link
    public func addFeed(link: String?) throws {
        let predicate = #Predicate<RSSFeed> { $0.link == link }
        let fetchFeed = FetchDescriptor(predicate: predicate)
        let newFeed = (try? modelExecutor.modelContext.fetch(fetchFeed))?.first ?? RSSFeed()

        newFeed.link = link
        newFeed.addDate = .now
        newFeed.title = link

        modelExecutor.modelContext.insert(newFeed)
    }

    /// Removes `RSSFeed` and associated items for the provided link
    /// - Parameter link: String value for the `RSSFeed` link
    public func deleteFeed(link: String?) throws {
        var descriptor = FetchDescriptor<RSSFeed>()
        descriptor.predicate = #Predicate<RSSFeed> { item in
            item.link == link
        }
        if let result = (try? modelExecutor.modelContext.fetch(descriptor))?.first {
            modelExecutor.modelContext.delete(result)
        }
    }
}

// MARK: Private Functions

extension FeedRepository {
    private func getFeedItemImageURLForDescriptionHTML(_ html: String?) throws -> URL? {
        guard let html else { return nil }

        let document = try SwiftSoup.parse(html)
        let srcs = try document.select("img[src]")
        let array = srcs.array().compactMap { try? $0.attr("src").description }
        return URL(string: array.first ?? "")
    }

    private func getFeedIconURL(for imageURL: String?, and link: String?) -> URL? {
        var imageString = ""
        if let imageURL {
            imageString = imageURL
        } else {
            imageString = "\(link ?? "")/favicon.ico"
        }
        return URL(string: imageString)
    }
}
