//
//  FeedOrder.swift
//
//
//  Created by Michael Kushinski on 11/9/23.
//

import Foundation

enum FeedOrder: String, CaseIterable {
    case new = "New"
    case unread = "Unread"
    case oldest = "Oldest"
    case newest = "Newest"
}
