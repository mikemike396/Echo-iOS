//
//  Collection+Extensions.swift
//
//
//  Created by Michael Kushinski on 10/27/23.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
