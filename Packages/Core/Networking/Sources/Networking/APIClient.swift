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

public class APIClient: APIInterface {
    public init() {}

    public func getRSSFeed(for url: URL?) async throws -> RSSFeedResponse? {
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
    }

    public func getSearchIndex() async throws -> [SearchIndexResponse]? {
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
    }

    public func putSearchIndexItem(for title: String, link: String) async throws {
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
}
