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
        context.autosaveEnabled = false
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.api = api
    }
    
    /// Calls Firebase to fetch the latest Search indexes
    public func getFeedSearchIndex() async throws {
        guard let results = try await api.getSearchIndex() else { return }

        let fetchSearchIndex = FetchDescriptor<SearchIndexItem>()
        let items = try? modelExecutor.modelContext.fetch(fetchSearchIndex)
        for item in items ?? [] {
            modelExecutor.modelContext.delete(item)
        }

        for item in results {
            let newItem = SearchIndexItem(id: item.id, title: item.item.title, link: item.item.url)

            modelExecutor.modelContext.insert(newItem)
        }
        try modelExecutor.modelContext.save()
    }

    /// Refreshes all the users `RSSFeed`s by calling `api.getRSSFeed` for each one
    public func syncFeeds() async throws {
        let fetchRSSFeeds = FetchDescriptor<RSSFeed>()
        let rssFeeds = try? modelExecutor.modelContext.fetch(fetchRSSFeeds)

        for rssFeed in rssFeeds ?? [] {
            let feedResponse = try await api.getRSSFeed(for: URL(string: rssFeed.link ?? ""))

            if let feedResponse,
               let link = rssFeed.link
            {
                try await updateFeed(for: link, with: feedResponse)
            }
        }
    }
    
    /// Updates or creates a new `RSSFeed` for the provided link and feedResponse
    /// - Parameters:
    ///   - link: `RSSFeed` link
    ///   - feedResponse: Response from the `api.getRSSFeed` endpoint
    public func updateFeed(for link: String, with feedResponse: RSSFeedResponse) async throws {
        let predicate = #Predicate<RSSFeed> { $0.link == link }
        let fetchFeed = FetchDescriptor(predicate: predicate)
        let newFeed = (try? modelExecutor.modelContext.fetch(fetchFeed))?.first ?? RSSFeed()

        newFeed.title = feedResponse.title
        newFeed.imageURL = getFeedIconURL(for: feedResponse.imageURL, and: feedResponse.link)
        newFeed.link = link
        if newFeed.addDate == nil {
            newFeed.addDate = .now
        }

        let items = feedResponse.items?.map { item in
            let newFeedItem = newFeed.items.first { $0.link == item.link } ?? RSSFeedItem()
            if newFeedItem.link == nil {
                newFeedItem.isNew = true
            } else {
                newFeedItem.isNew = false
            }
            newFeedItem.title = item.title
            newFeedItem.publishedDate = item.publishedDate
            newFeedItem.link = item.link
            newFeedItem.imageURL = getFeedItemImageURL(for: item)

            return newFeedItem
        }

        newFeed.items.append(contentsOf: items ?? [])
        modelExecutor.modelContext.insert(newFeed)
        try modelExecutor.modelContext.save()
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
        result?.isNew = false
        try modelExecutor.modelContext.save()
    }

    /// Adds a new `RSSFeed` item for the provided link
    /// - Parameter link: String value for the `RSSFeed` link
    public func addFeed(link: String?) async throws {
        var link = link
        /// Drop the last slash
        if link?.last == "/" {
            link = String(link?.dropLast() ?? "")
        }

        let feedResponse = try await api.getRSSFeed(for: URL(string: link ?? ""))

        if let feedResponse,
           let title = feedResponse.title,
           let link = link
        {
            /// Add feed to DB
            try await updateFeed(for: link, with: feedResponse)

            /// Fetch Latest Firebase Search Index
            try await getFeedSearchIndex()

            var descriptor = FetchDescriptor<SearchIndexItem>()
            descriptor.predicate = #Predicate<SearchIndexItem> { item in
                item.link == link
            }
            if (try? modelExecutor.modelContext.fetch(descriptor))?.first == nil {
                /// Send to Firebase Database if its not already in the index
                try await api.putSearchIndexItem(for: title, link: link)
            }
        }
    }

    /// Removes `RSSFeed` and associated items for the provided link
    /// - Parameter link: String value for the `RSSFeed` link
    public func deleteFeed(link: String?) throws {
        var descriptor = FetchDescriptor<RSSFeed>()
        descriptor.predicate = #Predicate<RSSFeed> { item in
            item.link == link
        }
        if let result = (try? modelExecutor.modelContext.fetch(descriptor))?.first {
            for item in result.items {
                modelExecutor.modelContext.delete(item)
            }
            modelExecutor.modelContext.delete(result)
            try modelExecutor.modelContext.save()
        }
    }
}

// MARK: Private Functions

extension FeedRepository {
    /// Parse description HTML field for image url
    /// - Parameter html: HTML string containing URL
    /// - Returns: Optional URL
    private func getFeedItemImageURLForDescriptionHTML(_ html: String?) throws -> URL? {
        guard let html else { return nil }

        let document = try SwiftSoup.parse(html)
        let srcs = try document.select("img[src]")
        let array = srcs.array().compactMap { try? $0.attr("src").description }
        return URL(string: array.first ?? "")
    }
    
    /// Parse feed icon URL
    /// - Parameters:
    ///   - imageURL: imageURL string to convert to URL
    ///   - link: Feed link to use if imageURL is nil which appends favicon.ico to end
    /// - Returns: Optional URL
    private func getFeedIconURL(for imageURL: String?, and link: String?) -> URL? {
        var imageString = ""
        if let imageURL {
            imageString = imageURL
        } else {
            imageString = "\(link ?? "")/favicon.ico"
        }
        return URL(string: imageString)
    }
    
    /// Parse feed item image URL
    /// - Parameter item: RSSFeedItem response
    /// - Returns: Optional URL
    private func getFeedItemImageURL(for item: RSSFeedItemResponse) -> URL? {
        /// Attempt to get image via MediaContents
        var mediaURL = item.mediaContentsURL
        if mediaURL == nil {
            /// Attempt to get image via Enclosure
            mediaURL = item.enclosureURL
            if mediaURL == nil {
                /// Attempt to get image via Description
                mediaURL = try? getFeedItemImageURLForDescriptionHTML(item.description)?.absoluteString
            }
        }

        return URL(string: mediaURL ?? "")
    }
}
