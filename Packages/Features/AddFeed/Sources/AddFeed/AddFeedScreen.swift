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

    // MARK: State Variables

    @State private var addFeedText: String = ""

    public init(feedRepo: FeedRepository = FeedRepository()) {
        self.feedRepo = feedRepo
    }

    public var body: some View {
        Form {
            addFeedSection
            editFeedSection
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Manage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: Components

extension AddFeedScreen {
    private var addFeedSection: some View {
        Section("Add Feed") {
            TextField("URL", text: $addFeedText)
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .autocorrectionDisabled(true)
                .onSubmit {
                    Task {
                        try? await feedRepo.addFeed(link: addFeedText)
                        addFeedText = ""
                    }
                }
        }
    }

    private var editFeedSection: some View {
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

#Preview {
    AddFeedScreen()
}
