import SwiftUI
import SwiftData

@MainActor
class NavigationRouter: ObservableObject {
    @Published var deepLinkGigID: UUID?
    @Published var deepLinkGigDestination: Gig?
}
