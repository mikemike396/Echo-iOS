//
//  FeedScreen.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

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

    let feedRepo: FeedRepository

    // MARK: SwiftData

    @Query(sort: \RSSFeedItem.publishedDate, order: .reverse) private var items: [RSSFeedItem]

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
                        cell(item: item)
                    }

                }
                .listRowSeparator(.visible)
            }
            .listStyle(.plain)
            .refreshable {
                try? await feedRepo.syncFeed()
            }
        }
        .navigationTitle("Feed")
    }

    private func cell(item: RSSFeedItem) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                WebImage(url: item.imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(20)
                Text(item.title ?? "")
                    .font(.body)
                    .foregroundStyle(item.hasRead ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            HStack(spacing: 5) {
                Spacer()
                WebImage(url: item.feed?.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                Text(formattedPublishedDate(item.publishedDate) ?? "")
                    .font(.footnote)
                    .frame(alignment: .trailing)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func navigateToLink(_ string: String?) {
        guard 
            let string,
            let url = URL(string: string)
        else { return }

        try? feedRepo.setItemRead(link: string)

        let vc = SFSafariViewController(url: url)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
    }

    private func formattedPublishedDate(_ date: Date?) -> String? {
        guard let date else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    FeedScreen()
        .modelContainer(for: RSSFeed.self, inMemory: true)
        .modelContainer(for: RSSFeedItem.self, inMemory: true)
}
