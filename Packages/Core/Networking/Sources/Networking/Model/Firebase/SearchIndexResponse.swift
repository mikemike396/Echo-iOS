//
//  SearchIndexResponse.swift
//
//
//  Created by Michael Kushinski on 11/1/23.
//

import Foundation

public struct SearchIndexResponse: Decodable {
    public let id: String
    public let item: SearchIndexItemResponse
}
