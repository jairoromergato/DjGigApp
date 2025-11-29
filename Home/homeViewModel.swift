import Combine

final class HomeViewModel: ObservableObject {
    @Published var actions: [HomeDestination] = [
        .gigs,
        .calendar,
        .images(id: nil),
        .soon
    ]
}
