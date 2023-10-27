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

private extension URL {
    static let nineToFiveMac = URL(string: "https://9to5mac.com/feed")
    static let macRumors = URL(string: "https://feeds.macrumors.com/MacRumors-All")
}

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
        let urls: [URL?] = [.nineToFiveMac, .macRumors]
        for url in urls {
            let feed = try await api.getRSSFeed(for: url)

            let predicate = #Predicate<RSSFeed> { $0.link == url?.absoluteString }
            let fetchFeed = FetchDescriptor(predicate: predicate)
            let newFeed = (try? modelExecutor.modelContext.fetch(fetchFeed))?.first ?? RSSFeed()

            var feedImageString = ""
            if let imageLink = feed?.image?.url {
                feedImageString = imageLink
            } else {
                feedImageString = "\(feed?.link ?? "")/favicon.ico"
            }
            let feedImageURL = URL(string: feedImageString)

            newFeed.title = feed?.title
            newFeed.link = url?.absoluteString
            newFeed.imageURL = feedImageURL

            let items = feed?.items?.compactMap { item in
                let newFeedItem = newFeed.items.first(where: { $0.link == item.link }) ?? RSSFeedItem()
                newFeedItem.title = item.title
                newFeedItem.publishedDate = item.pubDate
                newFeedItem.link = item.link
                newFeedItem.imageURL = try? getImageURLForDescriptionHTML(item.description)
                return newFeedItem
            }

            newFeed.items = items ?? []

            modelExecutor.modelContext.insert(newFeed)
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

    private func getImageURLForDescriptionHTML(_ html: String?) throws -> URL? {
        guard let html else { return nil }

        let document = try SwiftSoup.parse(html)
        let srcs = try document.select("img[src]")
        let array = srcs.array().compactMap { try? $0.attr("src").description }
        return URL(string: array.first ?? "")
    }
}
