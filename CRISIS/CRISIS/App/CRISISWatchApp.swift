import SwiftUI

@main
struct CRISISWatchApp: App {
    @State private var appState = AppState()
    @State private var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(appState)
                .environment(languageSettings)
                .environment(\.locale, languageSettings.locale)
                .preferredColorScheme(.light)
        }
    }
}
