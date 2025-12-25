import SwiftUI

@main
struct CRISISTahoeApp: App {
    @State private var appState = AppState()
    @State private var currencySettings = CurrencySettings()

    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environment(appState)
                .environment(currencySettings)
                .preferredColorScheme(.light)
        }
    }
}
