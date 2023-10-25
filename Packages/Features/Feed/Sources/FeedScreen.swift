//
//  FeedScreen.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Data
import SafariServices
import SwiftData
import SwiftUI
import Utilities

private extension URL {
    static let nineToFiveMac = URL(string: "https://9to5mac.com/feed/")
    static let macRumors = URL(string: "https://feeds.macrumors.com/MacRumors-All")
}

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
            }
            .listStyle(.plain)
        }
        .navigationTitle("Feed")
        .task {
            try? await feedRepo.fetchFeed(url: .nineToFiveMac)
            try? await feedRepo.fetchFeed(url: .macRumors)
        }
    }

    private func cell(item: RSSFeedItem) -> some View {
        HStack(alignment: .top, spacing: 0) {
            AsyncImage(url: item.feed?.imageURL) { image in
                image.image?.resizable()
            }
            .frame(width: 23, height: 23)
            .padding(.trailing, 12)

            Text(item.title ?? "")
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            Text(formattedPublishedDate(item.publishedDate) ?? "")
                .font(.footnote)
                .frame(alignment: .trailing)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
        }
    }

    private func navigateToLink(_ string: String?) {
        guard 
            let string,
            let url = URL(string: string)
        else { return }

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
}
