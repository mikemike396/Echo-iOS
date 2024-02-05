//
//  EchoModelContainer.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import SwiftData

final public class EchoModelContainer {
    public static let shared = EchoModelContainer()

    public init() {}
    
    public var container: ModelContainer = {
        let schema = Schema([
            RSSFeed.self,
            RSSFeedItem.self,
            SearchIndexItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
