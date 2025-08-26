import SwiftUI

@main
struct DartTrackerApp: App {
    @StateObject private var gameStore = GameStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(gameStore)
        }
    }
}


