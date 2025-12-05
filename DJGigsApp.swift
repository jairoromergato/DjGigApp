import SwiftUI
import SwiftData

@main
struct DjGigApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var router = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                SplashContainerView()
                    .preferredColorScheme(.dark)
            }
            .tint(AppTheme.accent)
            .background(AppTheme.bg)
            .listRowBackground(AppTheme.bg)
            .environmentObject(router)   
        }
        .modelContainer(for: [Gig.self])
    }
}
