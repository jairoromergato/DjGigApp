import SwiftUI
import SwiftData

@main
struct DjGigApp: App {
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
        }
        .modelContainer(for: [Gig.self])
    }
}
