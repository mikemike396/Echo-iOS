//
//  FeedView.swift
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

public struct FeedView: View {
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
            feed = try? await APIClient.getRSSFeed(for: .nineToFiveMac)
        }
    }

    private func cell(item: RSSFeedResponseItem) -> some View {
        VStack {
            Text(item.title ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            Text(item.description ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .lineLimit(4)
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
}

#Preview {
    FeedView()
}
