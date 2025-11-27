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
        let accent = UIColor(named: "BrandPrimary") ?? UIColor.label

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .secondarySystemBackground
        navAppearance.shadowColor = .separator
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.preferredFont(forTextStyle: .largeTitle)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = accent

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .systemBackground
        tabAppearance.shadowColor = .separator
        tabAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
