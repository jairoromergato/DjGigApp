import Foundation

enum HomeAction: CaseIterable, Identifiable {
    case gigs
    case calendar
    case soon

    var id: String { rawValue }

    private var rawValue: String {
        switch self {
        case .gigs: return "gigs"
        case .calendar: return "calendar"
        case .soon: return "soon"
        }
    }

    var title: String {
        switch self {
        case .gigs:
            return HomeStrings.gigsTitle
        case .calendar:
            return HomeStrings.calendarTitle
        case .soon:
            return HomeStrings.soonTitle
        }
    }

    var systemIcon: String {
        switch self {
        case .gigs:
            return "music.mic"
        case .calendar:
            return "calendar"
        case .soon:
            return "sparkles"
        }
    }
}
