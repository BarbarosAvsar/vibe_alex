import SwiftUI

@main
struct CRISISVisionApp: App {
    @State private var appState = AppState()
    @State private var currencySettings = CurrencySettings()
    @State private var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            VisionContentView()
                .environment(appState)
                .environment(currencySettings)
                .environment(languageSettings)
                .environment(\.locale, languageSettings.locale)
                .preferredColorScheme(.light)
        }
    }
}
