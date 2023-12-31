//
//  SearchIndexItemResponse.swift
//
//
//  Created by Michael Kushinski on 11/2/23.
//

import Foundation

public struct SearchIndexItemResponse: Decodable, Equatable {
    public let title: String
    public let url: String
}
