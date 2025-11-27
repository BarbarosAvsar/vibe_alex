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
                .preferredColorScheme(.dark)
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
        let accent = UIColor(named: "BrandWarm") ?? UIColor(red: 0.91, green: 0.73, blue: 0.78, alpha: 1.0)
        let background = UIColor(named: "BrandPrimary") ?? UIColor(red: 0.06, green: 0.11, blue: 0.24, alpha: 1.0)

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = background
        navAppearance.shadowColor = accent.withAlphaComponent(0.15)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "BrandCool") ?? UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "BrandCool") ?? UIColor.white,
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
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
