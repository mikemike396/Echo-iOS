//
//  APIInterface.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation
import FeedKit

public protocol APIInterface {
    func getRSSFeed(for url: URL?) async throws -> RSSFeed?
}
