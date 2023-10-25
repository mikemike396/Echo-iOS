//
//  EchoApp.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Data
import Feed
import SwiftData
import SwiftUI

@main
struct EchoApp: App {
    init() {
        print("App Directory Path: \(NSHomeDirectory())")
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedScreen()
            }
        }
        .modelContainer(EchoModelContainer.shared.modelContainer)
    }
}
