import SwiftUI
import BackgroundTasks
import UIKit

@MainActor
@main
struct VermoegensKompassApp: App {
    @State private var appState = AppState()
    @State private var currencySettings = CurrencySettings()

    init() {
        Appearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(currencySettings)
                .task {
                    BackgroundRefreshManager.shared.schedule()
                }
        }
        .backgroundTask(.appRefresh("de.vibecode.vermoegenskompass.refresh")) {
            await BackgroundRefreshManager.shared.handleBackgroundSceneTask(appState: appState)
        }
    }
}

private enum Appearance {
    static func configure() {
        guard
            let surface = UIColor(named: "BrandSurface"),
            let background = UIColor(named: "BrandBackground"),
            let accent = UIColor(named: "BrandAccent"),
            let textPrimary = UIColor(named: "BrandTextPrimary")
        else { return }

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = surface
        navAppearance.shadowColor = UIColor(named: "BrandBorder")
        navAppearance.titleTextAttributes = [
            .foregroundColor: textPrimary,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: textPrimary,
            .font: UIFont.preferredFont(forTextStyle: .largeTitle)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = accent

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = background
        tabAppearance.shadowColor = UIColor(named: "BrandBorder")
        tabAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
