import SwiftUI
import SwiftData

@main
struct DjGigApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                GigListView()
                    .preferredColorScheme(.dark)
            }
            .tint(AppTheme.accent) 
        }    
        .modelContainer(for: [Gig.self, Track.self])
        
    }
}
