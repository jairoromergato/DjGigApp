import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    static var router: NavigationRouter?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        let userInfo = response.notification.request.content.userInfo

        if let raw = userInfo["gigID"] as? String,
           let uuid = UUID(uuidString: raw) {

            print("🔗 Notificación toca gig con ID:", uuid)

            Task { @MainActor in
                AppDelegate.router?.deepLinkGigID = uuid
            }
        }

        completionHandler()
    }
}
