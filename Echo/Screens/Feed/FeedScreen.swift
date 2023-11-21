//
//  FeedScreen.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Data
import SafariServices
import SDWebImageSwiftUI
import SwiftData
import SwiftUI
import Utilities

struct FeedScreen: View {
    // MARK: Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: Initialization

    private let feedRepo: FeedRepository

    // MARK: SwiftData

    @Query(itemsFetchDescriptor, animation: .default) private var items: [RSSFeedItem]

    // MARK: Navigation

    @State private var path = NavigationPath()

    // MARK: State Variables

    @State private var addFeedPresented = false
    @State private var filterFeedPresented = false
    @State private var activeFilters = Set<String>()
    @State private var activeSort = FeedOrder.newest

    private var filteredItems: [RSSFeedItem] {
        var sortedItems = items

        /// Apply filters if we have any set
        if !activeFilters.isEmpty {
            sortedItems = items.filter { activeFilters.contains($0.feed?.link ?? "") }
        }

        /// Sort the items by selected FeedOrder
        switch activeSort {
        case .newest:
            sortedItems = sortedItems.sorted(by: { $0.publishedDate ?? .now > $1.publishedDate ?? .now })
        case .oldest:
            sortedItems = sortedItems.sorted(by: { $0.publishedDate ?? .now < $1.publishedDate ?? .now })
        case .unread:
            sortedItems = sortedItems.sorted(by: { !$0.hasRead && $1.hasRead })
        case .new:
            sortedItems = sortedItems.sorted(by: { $0.isNew && !$1.isNew })
        }
        return sortedItems
    }

    private static var itemsFetchDescriptor: FetchDescriptor<RSSFeedItem> {
        var fetchDescriptor = FetchDescriptor<RSSFeedItem>()
        fetchDescriptor.sortBy = [SortDescriptor(\RSSFeedItem.publishedDate, order: .reverse)]
        fetchDescriptor.fetchLimit = 250
        return fetchDescriptor
    }

    init(feedRepo: FeedRepository = FeedRepository()) {
        self.feedRepo = feedRepo
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    ForEach(filteredItems) { item in
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
            .navigationTitle("Feed")
            .navigationDestination(for: FeedTabScreen.self) { screen in
                FeedRouter(screen: screen)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        filterFeedPresented = true
                    } label: {
                        Image(systemName: activeFilters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    sortMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addFeedPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .environment(\.push, .init { path.append($0) })
        .environment(\.pop, .init { if !path.isEmpty { path.removeLast() }})
        .environment(\.popToRoot, .init { path = NavigationPath() })
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
        .sheet(isPresented: $filterFeedPresented) {
            FilterSheet(activeFilter: $activeFilters)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: Menus

extension FeedScreen {
    private var sortMenu: some View {
        Menu {
            Picker("", selection: $activeSort) {
                ForEach(FeedOrder.allCases, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
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
