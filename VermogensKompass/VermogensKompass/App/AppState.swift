import Foundation
import Observation
import UserNotifications

enum NotificationAuthorizationState: Equatable {
    case unknown
    case notDetermined
    case denied
    case authorized
    case provisional

    init(status: UNAuthorizationStatus?) {
        switch status {
        case .some(.authorized): self = .authorized
        case .some(.denied): self = .denied
        case .some(.provisional): self = .provisional
        case .some(.notDetermined): self = .notDetermined
        default: self = .unknown
        }
    }

    var requiresOnboarding: Bool {
        switch self {
        case .denied, .notDetermined, .provisional:
            return true
        default:
            return false
        }
    }
}

@MainActor
@Observable
final class AppState {
    private let repository: DashboardRepository
    private let cache = DashboardCache()

    var dashboardState: AsyncState<DashboardSnapshot> = .idle
    var lastUpdated: Date?
    var hasLoadedOnce = false
    var syncNotice: SyncNotice?
    var notificationStatus: NotificationAuthorizationState = .unknown

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
            await NotificationManager.shared.processHighPriorityAlert(from: snapshot.crises)
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

    func refreshNotificationAuthorizationStatus() async {
        let status = await NotificationManager.shared.authorizationStatus()
        notificationStatus = NotificationAuthorizationState(status: status)
    }

    func requestNotificationAccess() async -> Bool {
        let granted = await NotificationManager.shared.requestAuthorization()
        await refreshNotificationAuthorizationStatus()
        return granted
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
