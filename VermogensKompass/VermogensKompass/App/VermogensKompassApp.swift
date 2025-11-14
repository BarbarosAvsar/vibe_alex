import SwiftUI
import BackgroundTasks
import UIKit

@MainActor
@main
struct VermoegensKompassApp: App {
    @State private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    BackgroundRefreshManager.shared.configure { appState }
                    BackgroundRefreshManager.shared.schedule()
                }
        }
        .backgroundTask(.appRefresh("de.vibecode.vermoegenskompass.refresh")) {
            await BackgroundRefreshManager.shared.handleBackgroundSceneTask(appState: appState)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BackgroundRefreshManager.shared.prepareForLaunch()
        return true
    }
}
