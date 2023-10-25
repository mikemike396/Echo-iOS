//
//  APIInterface.swift
//
//
//  Created by Michael Kushinski on 10/25/23.
//

import Foundation
import Models

protocol APIInterface {
    func getRSSFeed(for url: URL?) async throws -> RSSFeedResponse?
}
