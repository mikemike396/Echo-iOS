//
//  AddFeedScreen.swift
//  Echo
//
//  Created by Michael Kushinski on 10/27/23.
//

import Data
import Utilities
import SwiftData
import SwiftUI

struct AddFeedScreen: View {
    // MARK: Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.feedRepository) private var feedRepository

    // MARK: SwiftData

    @Query(sort: \RSSFeed.addDate, order: .reverse, animation: .default) private var feeds: [RSSFeed]
    @Query(sort: \SearchIndexItem.title, animation: .default) private var searchIndexItems: [SearchIndexItem]

    // MARK: State Variables

    @State private var addFeedText: String = ""
    @State private var isSearchActive = false
    @State private var validURL = false
    @State private var linksLoading = Set<String>()

    var filteredSearchIndexItems: [SearchIndexItem] {
        let searchPredicate = #Predicate<SearchIndexItem> { item in
            item.title.localizedStandardContains(addFeedText) || item.link.localizedStandardContains(addFeedText)
        }
        return (try? searchIndexItems.filter(searchPredicate)) ?? []
    }

    var body: some View {
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
        .onChange(of: addFeedText) {
            validURL = validURL(addFeedText)
        }
    }
}

// MARK: Components

extension AddFeedScreen {
    @ViewBuilder private var searchSection: some View {
        List {
            if validURL && filteredSearchIndexItems.count == 0 {
                cell(with: addFeedText, and: addFeedText)
            }
            ForEach(filteredSearchIndexItems) { item in
                cell(with: item.title, and: item.link)
            }
        }
    }

    private func cell(with title: String, and link: String) -> some View {
        Button {
            linksLoading.insert(link)
            Task {
                if self.feedAdded(link: link) {
                    try? await feedRepository.deleteFeed(link: link)
                } else {
                    try? await feedRepository.addFeed(link: link)
                }
                linksLoading.remove(link)
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                if linksLoading.contains(link) {
                    ProgressView()
                } else if feedAdded(link: link) {
                    Image(systemName: "checkmark")
                        .font(.system(.body))
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .foregroundColor(Color(.label))
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
                                try? await feedRepository.deleteFeed(link: feed.link)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AddFeedScreen {
    private func validURL(_ string: String?) -> Bool {
        guard let string,
              let url = URL(string: string),
              UIApplication.shared.canOpenURL(url)
        else { return false }
        
        return true
    }

    private func feedAdded(link: String?) -> Bool {
        guard feeds.contains(where: { $0.link == link }) else { return false}
        return true
    }
}

#Preview {
    AddFeedScreen()
}
