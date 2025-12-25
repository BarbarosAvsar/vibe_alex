import SwiftUI

@main
struct CRISISWatchApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(appState)
                .preferredColorScheme(.light)
        }
    }
}
