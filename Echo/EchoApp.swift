//
//  EchoApp.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Feed
import SwiftUI

@main
struct EchoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedView()
            }
        }
    }
}
