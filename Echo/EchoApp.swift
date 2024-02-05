//
//  EchoApp.swift
//  Echo
//
//  Created by Michael Kushinski on 10/24/23.
//

import Data
import Firebase
import SDWebImage
import SwiftData
import SwiftUI

@main
struct EchoApp: App {
    @Environment(\.scenePhase) var scenePhase

    // MARK: Initialized Variables

    let modelContainer = EchoModelContainer.shared
    let feedRepository: FeedRepository

    // MARK: Private Variables

    @State private var hasEnteredBackground = false

    init() {
        print("App Directory Path: \(NSHomeDirectory())")
        
        feedRepository = FeedRepository(container: self.modelContainer.container)

        FirebaseApp.configure()

        // Never expires based on time
        SDImageCache.shared.config.maxDiskAge = -1
        // Expire after 500 MB
        SDImageCache.shared.config.maxDiskSize = 1000 * 1000 * 500
    }

    var body: some Scene {
        WindowGroup {
            FeedScreen()
                .environment(\.feedRepository, feedRepository)
        }
        .onChange(of: scenePhase, initial: false) { _, newPhase in
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
        .modelContainer(modelContainer.container)
    }

    private func syncFeeds() {
        Task.detached {
            try? await feedRepository.syncFeeds()
            try? await feedRepository.getFeedSearchIndex()
        }
    }
}
