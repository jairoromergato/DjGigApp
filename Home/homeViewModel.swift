import Foundation

@Observable
final class HomeViewModel {
    var actions: [HomeAction] = [.gigs, .soon]

}
