import SwiftUI
import BackgroundTasks
import UIKit

@MainActor
@main
struct CRISISApp: App {
    @State private var appState = AppState()
    @State private var currencySettings = CurrencySettings()
    @State private var languageSettings = LanguageSettings()

    init() {
        Appearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(currencySettings)
                .environment(languageSettings)
                .environment(\.locale, languageSettings.locale)
                .preferredColorScheme(.light)
                .task {
                    BackgroundRefreshManager.shared.schedule()
                }
        }
        .backgroundTask(.appRefresh("de.vibecode.crisis.refresh")) {
            await BackgroundRefreshManager.shared.handleBackgroundSceneTask(appState: appState)
        }
    }
}

private enum Appearance {
    static func configure() {
        let accent = UIColor(named: "BrandWarm") ?? UIColor(red: 0.902, green: 0.639, blue: 0.690, alpha: 1.0)
        let background = UIColor(named: "BrandPrimary") ?? UIColor(red: 0.059, green: 0.110, blue: 0.239, alpha: 1.0)
        let text = UIColor(named: "BrandWarm") ?? accent

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = background
        navAppearance.shadowColor = accent.withAlphaComponent(0.15)
        navAppearance.titleTextAttributes = [
            .foregroundColor: text,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: text,
            .font: UIFont.preferredFont(forTextStyle: .largeTitle)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = accent

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = background
        tabAppearance.shadowColor = accent.withAlphaComponent(0.15)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = text.withAlphaComponent(0.6)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: text.withAlphaComponent(0.75)]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
