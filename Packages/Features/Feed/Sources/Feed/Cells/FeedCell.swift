//
//  FeedCell.swift
//
//
//  Created by Michael Kushinski on 10/26/23.
//

import Data
import SDWebImageSwiftUI
import SwiftUI

struct FeedCell: View {
    let item: RSSFeedItem

    var body: some View {
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
}

// MARK: Private Functions

extension FeedCell {
    private func formattedPublishedDate(_ date: Date?) -> String? {
        guard let date else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    FeedCell(item: RSSFeedItem())
}
