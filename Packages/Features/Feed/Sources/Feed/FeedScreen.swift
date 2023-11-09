//
//  FeedScreen.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import AddFeed
import Data
import SafariServices
import SDWebImageSwiftUI
import SwiftData
import SwiftUI
import Utilities

public struct FeedScreen: View {
    // MARK: Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: Initialization

    private let feedRepo: FeedRepository

    // MARK: SwiftData

    @Query(itemsFetchDescriptor, animation: .default) private var items: [RSSFeedItem]

    // MARK: State Variables

    @State private var addFeedPresented = false

    private static var itemsFetchDescriptor: FetchDescriptor<RSSFeedItem> {
        var fetchDescriptor = FetchDescriptor<RSSFeedItem>()
        fetchDescriptor.sortBy = [SortDescriptor(\RSSFeedItem.publishedDate, order: .reverse)]
        fetchDescriptor.fetchLimit = 250
        return fetchDescriptor
    }

    public init(feedRepo: FeedRepository = FeedRepository()) {
        self.feedRepo = feedRepo
    }

    public var body: some View {
        VStack {
            List {
                ForEach(items) { item in
                    Button {
                        navigateToLink(item.link)
                    } label: {
                        FeedCell(item: item)
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                try? await feedRepo.syncFeeds()
            }
        }
        .toolbar {
            Button {
                addFeedPresented = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            if items.count == 0 {
                addFeedPresented = true
            }
        }
        .sheet(isPresented: $addFeedPresented) {
            NavigationStack {
                AddFeedScreen()
            }
        }
        .navigationTitle("Feed")
    }
}

// MARK: Private Functions

extension FeedScreen {
    private func navigateToLink(_ string: String?) {
        guard
            let string,
            let url = URL(string: string)
        else { return }

        Task {
            try? await feedRepo.setItemRead(link: string)
        }

        let sfViewController = SFSafariViewController(url: url)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(sfViewController, animated: true)
    }
}

#Preview {
    FeedScreen()
}
