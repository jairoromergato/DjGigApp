import Combine

final class HomeViewModel: ObservableObject {
    @Published var actions: [HomeAction] = [
        .gigs,
        .calendar,
        .soon
    ]
}
