import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    private init() {}

    func requestAuthorization() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        isAuthorized = true
    }

    func scheduleBedtimeReminder(at hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to wind down"
        content.body = "Ready to log your sleep?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "bedtime_reminder", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Notification scheduling error: \(error)")
        }
    }

    func removeBedtimeReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtime_reminder"])
    }
}
