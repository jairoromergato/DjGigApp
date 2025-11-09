import SwiftUI

struct HomeRouter {
    @ViewBuilder
    func destination(for action: HomeAction) -> some View {
        switch action {
        case .gigs:
            GigListView()
        case .soon:
            Text("Próximamente ✨").font(.title)
        }
    }
}
