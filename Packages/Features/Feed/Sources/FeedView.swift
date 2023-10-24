//
//  ContentView.swift
//
//  Created by Michael Kushinski on 10/24/23.
//

import Core
import FeedKit
import SwiftUI

public struct FeedView: View {
    @State var feed: RSSFeed?

    public init() {

    }
    
    public var body: some View {
        VStack {
            List {
                ForEach(feed?.items ?? [], id: \.title) { item in
                    Text(item.title ?? "")
                }
            }
        }
        .task {
            feed = try? await APIClient.getRSSFeed(for: URL(string: "https://9to5mac.com/feed/")!)
        }
    }
}

#Preview {
    FeedView()
}
