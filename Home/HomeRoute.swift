import SwiftUI

struct HomeRouter {
    @ViewBuilder
    func destination(for action: HomeAction) -> some View {
        switch action {
        case .gigs:
            GigListView()              // Sección de bolos
        case .calendar:
            CalendarView()             // Sección de calendario
        case .soon:
            Text("Próximamente ✨")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}
