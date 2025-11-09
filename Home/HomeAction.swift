import Foundation

enum HomeAction: CaseIterable, Identifiable {
    case gigs
    case soon

    var id: String { String(describing: self) }

    var title: String {
        switch self {
        case .gigs: return HomeStrings.gigsTitle
        case .soon: return HomeStrings.soonTitle
        }
    }

    var systemIcon: String {
        switch self {
        case .gigs: return "music.mic"
        case .soon: return "sparkles"
        }
    }
}
