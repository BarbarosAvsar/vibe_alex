import SwiftUI

@main
struct CRISISVisionApp: App {
    @State private var appState = AppState()
    @State private var currencySettings = CurrencySettings()

    var body: some Scene {
        WindowGroup {
            VisionContentView()
                .environment(appState)
                .environment(currencySettings)
                .preferredColorScheme(.light)
        }
    }
}
