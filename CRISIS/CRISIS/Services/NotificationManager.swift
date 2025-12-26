import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let lastNotificationKey = "lastNotifiedCrisisID"
    private let languageKey = "preferredLanguage"

    private override init() {
        super.init()
        center.delegate = self
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        let currentStatus = await authorizationStatus()
        switch currentStatus {
        case .authorized:
            return true
        case .denied:
            return false
        case .provisional:
            return true
        default:
            do {
                return try await center.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                #if DEBUG
                print("Notification authorization failed", error)
                #endif
                return false
            }
        }
    }

    func processHighPriorityAlert(from events: [CrisisEvent]) async {
        let status = await authorizationStatus()
        guard status == .authorized else { return }
        guard let event = events.sorted(by: { $0.severityScore > $1.severityScore }).first,
              event.severityScore >= CrisisThresholds.highRiskSeverityScore else { return }

        if defaults.string(forKey: lastNotificationKey) == event.id { return }
        defaults.set(event.id, forKey: lastNotificationKey)

        let language = selectedLanguage
        let eventTitle = localizedCrisisEventTitle(event, language: language)
        let regionLabel = localizedWatchlistCountry(event.region, language: language)
        let categoryLabel = event.category.localizedLabel(language: language)

        let content = UNMutableNotificationContent()
        content.title = Localization.format("crisis_notification_title", language: language, eventTitle)
        content.body = Localization.format("crisis_notification_body", language: language, regionLabel, categoryLabel)
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        do {
            try await center.add(request)
        } catch {
            #if DEBUG
            print("Failed to schedule notification", error)
            #endif
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    private var selectedLanguage: AppLanguage {
        if let stored = defaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: stored) {
            return language
        }
        return .german
    }
}
