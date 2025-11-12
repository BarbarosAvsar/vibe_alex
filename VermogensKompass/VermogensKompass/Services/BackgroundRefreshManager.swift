import BackgroundTasks
import SwiftUI

@MainActor
final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    private init() { }

    private let identifier = "de.vibecode.vermoegenskompass.refresh"
    private var appStateProvider: (() -> AppState?)?

    func configure(appStateProvider: @escaping () -> AppState?) {
        self.appStateProvider = appStateProvider
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { [weak self] task in
            Task { await self?.handle(task: task as? BGAppRefreshTask) }
        }
    }

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

    private func handle(task: BGAppRefreshTask?) async {
        guard let task else { return }
        schedule()
        let operation = Task {
            if let appState = appStateProvider?() {
                await appState.refreshDashboard(force: true)
            }
        }
        task.expirationHandler = {
            operation.cancel()
        }
        await operation.value
        task.setTaskCompleted(success: true)
    }
}
