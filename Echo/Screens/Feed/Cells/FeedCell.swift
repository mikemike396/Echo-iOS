//
//  FeedCell.swift
//  Echo
//
//  Created by Michael Kushinski on 10/26/23.
//

import Data
import SDWebImageSwiftUI
import SwiftUI

struct FeedCell: View {
    let item: RSSFeedItem
    @State private var imageURLFailed = false

    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .top, spacing: 12) {
                Text(item.title ?? "")
                    .font(.body)
                    .foregroundStyle(item.hasRead ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                WebImage(url: item.imageURL)
                    .placeholder {
                        if imageURLFailed {
                            ZStack {
                                Rectangle()
                                    .fill(.separator.opacity(0.5))
                                Image("echo-icon")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .onSuccess { _, _, _ in
                        imageURLFailed = false
                    }
                    .onFailure { _ in
                        imageURLFailed = true
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(20)
            }
            HStack(spacing: 5) {
                WebImage(url: item.feed?.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                Text(formattedPublishedDate(item.publishedDate) ?? "")
                    .font(.footnote)
                    .frame(alignment: .trailing)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                if item.isNew {
                    Circle()
                        .fill(.teal)
                        .frame(width: 6, height: 6)
                }
                Spacer()
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
