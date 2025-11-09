import Foundation
import SwiftData

@Model
final class Gig {
    @Attribute(.unique) var id: UUID
    var date: Date
    var eventName: String
    var venue: String
    var fee: Double
    var durationMinutes: Int
    var style: String
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = .init(),
        eventName: String = "",
        venue: String = "",
        fee: Double = 0,
        durationMinutes: Int = 0,
        style: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.eventName = eventName
        self.venue = venue
        self.fee = fee
        self.durationMinutes = durationMinutes
        self.style = style
        self.notes = notes
    }
}
