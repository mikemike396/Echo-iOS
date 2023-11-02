//
//  EchoApp.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Data
import Feed
import Firebase
import SDWebImage
import SwiftData
import SwiftUI

@main
struct EchoApp: App {
    @Environment(\.scenePhase) var scenePhase

    // MARK: Initialized Variables

    let container: ModelContainer

    // MARK: Private Variables

    @State private var hasEnteredBackground = false

    init() {
        container = EchoModelContainer.shared.modelContainer
        print("App Directory Path: \(NSHomeDirectory())")

        FirebaseApp.configure()

        // Never expires based on time
        SDImageCache.shared.config.maxDiskAge = -1
        // Expire after 500 MB
        SDImageCache.shared.config.maxDiskSize = 1000 * 1000 * 500
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
                if !hasEnteredBackground {
                    syncFeeds()
                }
            case .background:
                hasEnteredBackground = true
            default:
                break
            }
        }
        .modelContainer(container)
    }

    private func syncFeeds() {
        Task.detached {
            let feedRepository = FeedRepository()
            try? await feedRepository.syncFeeds()

            try? await feedRepository.getFeedSearchIndex()
        }
    }
}
