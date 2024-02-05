//
//  APIClient.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import FeedKit
import Firebase
import FirebaseDatabase
import Foundation
import SwiftUI
import Utilities

public struct APIClient {
    public var getRSSFeed: (_ url: URL?) async throws -> RSSFeedResponse?
    public var getSearchIndex: () async throws -> [SearchIndexResponse]?
    public var putSearchIndexItem: (_ title: String, _ link: String) async throws -> Void
}

extension APIClient {
    public static let liveValue = Self(
        getRSSFeed: { url in
            guard let url else { throw APIError.invalidURL }

            let parser = FeedParser(URL: url)
            return try await withCheckedThrowingContinuation { continuation in
                parser.parseAsync { result in
                    switch result {
                    case .success(let feed):
                        continuation.resume(returning: RSSFeedResponse(rssFeed: feed.rssFeed))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        },

        getSearchIndex: {
            do {
                let databaseReference = Database.database().reference()

                databaseReference.database.goOnline()
                let rawData = try await databaseReference.getData()
                databaseReference.database.goOffline()

                guard rawData.exists(),
                      let rawData = rawData.value,
                      let jsonData = try? JSONSerialization.data(withJSONObject: rawData)
                else { return nil }

                let response = try? JSONDecoder().decode([String: SearchIndexItemResponse].self, from: jsonData)
                let results = response?.map { item in
                    SearchIndexResponse(id: item.key, item: SearchIndexItemResponse(title: item.value.title, url: item.value.url))
                }
                return results
            } catch {
                throw error
            }
        },

        putSearchIndexItem: { title, link in
            do {
                let databaseReference = Database.database().reference()
                databaseReference.database.goOnline()
                let newItem = databaseReference.childByAutoId()

                try await newItem.updateChildValues(["title": title, "url": link])
                databaseReference.database.goOffline()

            } catch {
                throw error
            }
        }
    )

    public static var testValue = Self(
        getRSSFeed: { _ in
            var rssFeed = RSSFeed()
            rssFeed.title = "9to5mac"
            rssFeed.link = "https://9to5mac.com"
            return RSSFeedResponse(rssFeed: rssFeed)
        },

        getSearchIndex: {
            [SearchIndexResponse(id: "123", item: SearchIndexItemResponse(title: "9to5mac", url: "https://9to5mac.com"))]
        },

        putSearchIndexItem: { title, link in
            guard !title.isEmpty, !link.isEmpty else { throw "Error" }
        }
    )
}

extension EnvironmentValues {
    private enum APIClientKey: EnvironmentKey {
        static let defaultValue = APIClient.liveValue
    }

    public var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
