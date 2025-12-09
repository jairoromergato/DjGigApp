import SwiftUI
import SwiftData

struct HomeRouter {
    @ViewBuilder
    func destination(for action: HomeDestination, gigs: [Gig]) -> some View {
        switch action {
        case .gigs:
            GigListView()
        case .calendar:
            CalendarView()
        case .images:
            GigAllImagesView(gig: nil)
        case .redesSociales:
            SocialView()
        case .soon:
            Text("Próximamente ✨")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}
