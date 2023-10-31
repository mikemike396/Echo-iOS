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

    @Query(sort: \RSSFeedItem.publishedDate, order: .reverse, animation: .default) private var items: [RSSFeedItem]

    // MARK: State Variables

    @State private var addFeedPresented = false

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
                .listRowSeparator(.visible)
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

        let vc = SFSafariViewController(url: url)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
    }
}

#Preview {
    FeedScreen()
        .modelContainer(for: RSSFeed.self, inMemory: true)
        .modelContainer(for: RSSFeedItem.self, inMemory: true)
}
