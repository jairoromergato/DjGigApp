import Foundation

enum HomeDestination: Identifiable {
    case gigs
    case calendar
    case images(id: String?)
    case redesSociales
    case soon
    

    var id: String { rawValue }

    private var rawValue: String {
        switch self {
        case .gigs: return "gigs"
        case .calendar: return "calendar"
        case .images: return "image"
        case . redesSociales: return "redes sociales"
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
        case .redesSociales:
            return HomeStrings.redesSocialesTitle
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
        case .redesSociales:
            return "link.circle"
        case .soon:
            return "ellipsis.circle"
        }
    }
}
