import BackgroundTasks
import SwiftUI

@MainActor
final class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    private init() { }

    private let identifier = "de.vibecode.vermoegenskompass.refresh"
    private var appStateProvider: (() -> AppState?)?
    private var didRegisterTask = false

    func configure(appStateProvider: @escaping () -> AppState?) {
        self.appStateProvider = appStateProvider
        guard didRegisterTask == false else { return }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { [weak self] task in
            Task { await self?.handle(task: task as? BGAppRefreshTask) }
        }
        didRegisterTask = true
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
        let operation = Task<Void, Error> {
            try Task.checkCancellation()
            if let appState = appStateProvider?() {
                await appState.refreshDashboard(force: true)
            }
        }
        task.expirationHandler = {
            operation.cancel()
        }

        do {
            _ = try await operation.value
            task.setTaskCompleted(success: true)
        } catch is CancellationError {
            task.setTaskCompleted(success: false)
        } catch {
            #if DEBUG
            print("Background task failed", error)
            #endif
            task.setTaskCompleted(success: false)
        }
    }
}
