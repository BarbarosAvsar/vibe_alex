import BackgroundTasks
import SwiftUI

@MainActor
final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    private init() { }

    private let identifier = "de.vibecode.vermoegenskompass.refresh"

    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            #if DEBUG
            print("Failed to schedule background refresh", error)
            #endif
        }
    }

    func handleBackgroundSceneTask(appState: AppState) async {
        await appState.refreshDashboard(force: true)
        schedule()
    }
}
