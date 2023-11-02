//
//  AddFeedScreen.swift
//
//
//  Created by Michael Kushinski on 10/27/23.
//

import Data
import Utilities
import SwiftData
import SwiftUI

public struct AddFeedScreen: View {
    // MARK: Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: Initialization

    private let feedRepo: FeedRepository

    // MARK: SwiftData

    @Query(sort: \RSSFeed.addDate, order: .reverse, animation: .default) private var feeds: [RSSFeed]
    @Query(sort: \SearchIndexItem.title, animation: .default) private var searchIndexItems: [SearchIndexItem]

    // MARK: State Variables

    @State private var addFeedText: String = ""
    @State private var isSearchActive = false

    var filteredSearchIndexItems: [SearchIndexItem] {
        let searchPredicate = #Predicate<SearchIndexItem> {
            $0.title.localizedStandardContains(addFeedText)
        }
        return (try? searchIndexItems.filter(searchPredicate)) ?? []
    }

    public init(feedRepo: FeedRepository = FeedRepository()) {
        self.feedRepo = feedRepo
    }

    public var body: some View {
        Form {
            searchSection
            editFeedSection
        }
        .background(Color(.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Manage")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $addFeedText, isPresented: $isSearchActive, placement: .navigationBarDrawer(displayMode: .always), prompt: "Type a name, or paste a URL")
    }
}

// MARK: Components

extension AddFeedScreen {
    @ViewBuilder private var searchSection: some View {
        List {
            ForEach(filteredSearchIndexItems) { item in
                Button {
                    addFeedText = ""
                    isSearchActive = false
                    Task {
                        try? await feedRepo.addFeed(link: item.url.absoluteString)

                    }
                } label: {
                    NavigationLink(item.title, destination: EmptyView())
                }
                .foregroundColor(Color(uiColor: .label))
            }
        }
    }

    @ViewBuilder private var editFeedSection: some View {
        if !isSearchActive {
            Section("Edit Feeds") {
                List {
                    ForEach(feeds) { item in
                        Text(item.title ?? "")
                    }
                    .onDelete { indexSet in
                        Task {
                            if let index = indexSet.first,
                               let feed = feeds[safe: index]
                            {
                                try? await feedRepo.deleteFeed(link: feed.link)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddFeedScreen()
}
