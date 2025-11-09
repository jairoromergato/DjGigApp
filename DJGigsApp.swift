import SwiftUI
import SwiftData

@main
struct DjGigApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                HomeView()
                    .preferredColorScheme(.dark)
            }
            .tint(AppTheme.accent)
        }
        // Solo el modelo de bolos
        .modelContainer(for: [Gig.self])
    }
}
