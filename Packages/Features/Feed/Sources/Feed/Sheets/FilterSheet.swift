//
//  FilterSheet.swift
//
//
//  Created by Michael Kushinski on 11/9/23.
//

import Data
import SwiftData
import SwiftUI

struct FilterSheet: View {
    @Binding var activeFilter: Set<String>

    @Query(sort: \RSSFeed.title, order: .forward, animation: .default) private var feeds: [RSSFeed]

    var body: some View {
        List {
            ForEach(feeds) { item in
                cell(item: item)
            }
        }
    }
}

// MARK: Components

extension FilterSheet {
    func cell(item: RSSFeed) -> some View {
        Button {
            if let link = item.link {
                if activeFilter.contains(link) {
                    activeFilter.remove(link)
                } else {
                    activeFilter.insert(link)
                }
            }
        } label: {
            HStack {
                Text(item.title ?? "")
                Spacer()
                if activeFilter.contains(item.link ?? "") {
                    Image(systemName: "checkmark")
                        .font(.system(.body))
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .foregroundColor(Color(.label))
    }
}

#Preview {
    FilterSheet(activeFilter: .constant(["Test", "Test"]))
}
