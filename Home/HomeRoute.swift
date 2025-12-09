import SwiftUI
import SwiftData

struct HomeRouter {
    @ViewBuilder
    func destination(for action: HomeDestination, gigs: [Gig]) -> some View {
        switch action {
        case .gigs:
            GigListView()
                .appBackground()
        case .calendar:
            CalendarView()
                .appBackground()
        case .images:
            GigAllImagesView(gig: nil)
                .appBackground()
        case .redesSociales:
            SocialView()
                .appBackground()
        case .soon:
            Text("Próximamente ✨")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.title)
                .appBackground()
        }
    }
}
