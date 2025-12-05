import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("ERROR permiso notificaciones:", error.localizedDescription)
            } else {
                print("Permiso concedido:", granted)
            }
        }
    }

    func scheduleNotification(for gig: Gig) {
        let calendar = Calendar.current
        let now = Date()

        let offsets: [(component: Calendar.Component, value: Int, label: String)] = [
            (.day,  -7, "en 1 semana"),
            (.day,  -1, "mañana"),
            (.hour, -1, "en 1 hora")
        ]

        for (component, value, label) in offsets {
            guard let reminderDate = calendar.date(byAdding: component, value: value, to: gig.date) else {
                continue
            }

            guard reminderDate > now else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "Bolo: \(gig.eventName)"
            content.subtitle = "Empieza \(label)"
            content.body =
            """
            Lugar: \(gig.venue)
            Fecha: \(gig.date.formatted(date: .abbreviated, time: .shortened))
            """
            content.sound = .default

            content.userInfo = [
                "gigID": gig.id.uuidString
            ]

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error notificando:", error.localizedDescription)
                } else {
                    print("🔔 Notificación programada \(label) para el bolo \(gig.eventName) en:", reminderDate)
                }
            }
        }
    }
}
