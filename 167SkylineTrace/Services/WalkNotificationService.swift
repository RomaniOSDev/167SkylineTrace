import Foundation
import UserNotifications

enum WalkNotificationService {
    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    static func scheduleReminders(settings: ReminderSettings) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard settings.isEnabled, !settings.weekdayNumbers.isEmpty else { return }

        for weekday in settings.weekdayNumbers {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = settings.hour
            components.minute = settings.minute

            let content = UNMutableNotificationContent()
            content.title = "Time for a night walk"
            content.body = "The city is waiting. Log your route and mood tonight."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "skyline.reminder.\(weekday)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
}
