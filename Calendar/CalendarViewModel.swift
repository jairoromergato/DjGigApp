import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDate: Date

    init(now: Date = Date()) {
        let cal = Calendar.autoupdatingCurrent
        let comps = cal.dateComponents([.year, .month], from: now)
        self.currentMonth = cal.date(from: comps) ?? now
        self.selectedDate = now
    }

    func nextMonth() {
        if let d = Calendar.autoupdatingCurrent.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = d
        }
    }

    func prevMonth() {
        if let d = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = d
        }
    }
}
