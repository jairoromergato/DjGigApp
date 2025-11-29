import Foundation

enum HomeDestination: Identifiable {
    case gigs
    case calendar
    case images(id: String?)
    case soon

    var id: String { rawValue }

    private var rawValue: String {
        switch self {
        case .gigs: return "gigs"
        case .calendar: return "calendar"
        case .images: return "image"
        case .soon: return "soon"
        }
    }

    var title: String {
        switch self {
        case .gigs:
            return HomeStrings.gigsTitle
        case .calendar:
            return HomeStrings.calendarTitle
        case .images:
            return HomeStrings.imagesTitle
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
        case .images:
            return "photo.on.rectangle.angled"
        case .soon:
            return "ellipsis.circle"
        }
    }
}
