import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let lastNotificationKey = "lastNotifiedCrisisID"

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus != .authorized else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func processHighPriorityAlert(from events: [CrisisEvent]) {
        guard let event = events.sorted(by: { $0.severityScore > $1.severityScore }).first,
              event.severityScore >= 5 else { return }

        if defaults.string(forKey: lastNotificationKey) == event.id { return }
        defaults.set(event.id, forKey: lastNotificationKey)

        let content = UNMutableNotificationContent()
        content.title = "Krisenlage: \(event.title)"
        content.body = "Region: \(event.region). Kategorie: \(event.category.rawValue.capitalized)."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
