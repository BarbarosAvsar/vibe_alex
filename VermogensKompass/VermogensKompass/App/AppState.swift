import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    private let repository: DashboardRepository
    private let cache = DashboardCache()

    var dashboardState: AsyncState<DashboardSnapshot> = .idle
    var lastUpdated: Date?
    var hasLoadedOnce = false
    var syncNotice: SyncNotice?

    init(repository: DashboardRepository = DashboardRepository()) {
        self.repository = repository
    }

    func refreshDashboard(force: Bool = false) async {
        guard force || dashboardState.isLoading == false else { return }
        dashboardState = .loading
        syncNotice = nil

        do {
            let snapshot = try await repository.makeSnapshot()
            dashboardState = .loaded(snapshot)
            lastUpdated = Date()
            hasLoadedOnce = true
            cache.persist(snapshot)
            NotificationManager.shared.processHighPriorityAlert(from: snapshot.crises)
            syncNotice = nil
        } catch {
            let fallback = cache.load() ?? MockData.snapshot
            dashboardState = .loaded(fallback)
            syncNotice = SyncNotice(
                lastSuccessfulSync: lastUpdated,
                errorDescription: error.friendlyMessage
            )
        }
    }
}

struct SyncNotice: Equatable {
    let lastSuccessfulSync: Date?
    let errorDescription: String
}

private extension AsyncState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

private extension Error {
    var friendlyMessage: String {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
}
