//
//  Item.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
