import Foundation
import SwiftData

@Model
final class Gig {
    @Attribute(.unique) var id: UUID
    var eventName: String
    var date: Date
    var venue: String
    var feeEUR: Decimal
    var durationMinutes: Int
    var style: String
    var notes: String
//    var tracks: [Track] = []
    @Relationship var tracks: [Track] = []
    
    init(
        id: UUID = UUID(),
        eventName: String = "",
        date: Date = Date(),
        venue: String,
        feeEUR: Decimal,
        durationMinutes: Int,
        style: String,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.venue = venue
        self.feeEUR = feeEUR
        self.durationMinutes = durationMinutes
        self.style = style
        self.notes = notes
        self.eventName = eventName
    }
}

@Model
final class Track {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String

    var titleKey: String
    var artistKey: String

    @Relationship(deleteRule: .nullify)
      var tracks: [Track] = []

    init(id: UUID = UUID(), title: String, artist: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.titleKey = title.lowercased()
        self.artistKey = artist.lowercased()
    }

    var titleObserved: String {
        get { title }
        set { title = newValue; titleKey = newValue.lowercased() }
    }
    var artistObserved: String {
        get { artist }
        set { artist = newValue; artistKey = newValue.lowercased() }
    }
}

func durationString(_ minutes: Int) -> String {
    let h = minutes / 60
    let m = minutes % 60
    switch (h, m) {
    case (0, _): return "\(m) min"
    case (_, 0): return "\(h) h"
    default:     return "\(h) h \(m) min"
    }
}
