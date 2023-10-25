//
//  FeedScreen.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Core
import FeedKit
import Models
import SafariServices
import SwiftUI

private extension URL {
    static let nineToFiveMac = URL(string: "https://9to5mac.com/feed/")
}

public struct FeedScreen: View {
    @State var feed: RSSFeedResponse?

    public init() {}
    
    public var body: some View {
        VStack {
            List {
                ForEach(feed?.items ?? []) { item in
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
            feed = try? await APIClient().getRSSFeed(for: .nineToFiveMac)
        }
    }

    private func cell(item: RSSFeedResponseItem) -> some View {
        HStack(alignment: .top, spacing: 0) {
            AsyncImage(url: feed?.imageURL) { image in
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
