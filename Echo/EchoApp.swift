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
    @Environment(\.scenePhase) var scenePhase
    let feedRepository = FeedRepository()

    init() {
        print("App Directory Path: \(NSHomeDirectory())")
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedScreen()
            }
        }
        .onChange(of: scenePhase, initial: false) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                Task {
                    try? await feedRepository.syncFeed()
                }
            default:
                break
            }
        }
        .modelContainer(EchoModelContainer.shared.modelContainer)
    }
}
