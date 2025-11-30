import SwiftUI

struct MonthGrid: View {
    let month: Date
    let gigsByDay: [Date: [Gig]]
    let onSelectDay: (Date) -> Void

    private var cal: Calendar {
        let c = Calendar.autoupdatingCurrent
        return c
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = cal

        let raw = formatter.shortStandaloneWeekdaySymbols
            ?? formatter.shortWeekdaySymbols
            ?? ["L", "M", "X", "J", "V", "S", "D"]

        let symbols = raw

        let first = cal.firstWeekday - 1
        let reordered = Array(symbols[first...] + symbols[..<first])

        return reordered
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 8) {

            HStack {
                ForEach(weekdaySymbols, id: \.self) { s in
                    Text(s.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysInMonth(), id: \.self) { day in
                    DayCell(
                        date: day,
                        isInMonth: cal.isDate(day, equalTo: month, toGranularity: .month),
                        gigsCount: gigsByDay[cal.startOfDay(for: day)]?.count ?? 0
                    )
                    .onTapGesture { onSelectDay(day) }
                }
            }
            .padding(.vertical, 6)
            .background(AppTheme.card.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func daysInMonth() -> [Date] {
        let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!

        let range = cal.range(of: .day, in: .month, for: start)!

        let weekday = cal.component(.weekday, from: start)
        let offset = (weekday - cal.firstWeekday + 7) % 7

        var days: [Date] = []

        if offset > 0 {
            for i in 0..<offset {
                let d = cal.date(byAdding: .day, value: -(offset - i), to: start)!
                days.append(d)
            }
        }

        for d in range {
            let day = cal.date(byAdding: .day, value: d - 1, to: start)!
            days.append(day)
        }

        while days.count % 7 != 0 {
            let next = cal.date(byAdding: .day, value: 1, to: days.last!)!
            days.append(next)
        }

        return days
    }
}

private struct DayCell: View {
    let date: Date
    let isInMonth: Bool
    let gigsCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Calendar.autoupdatingCurrent.component(.day, from: date))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isInMonth ? .primary : .secondary)

            HStack(spacing: 3) {
                ForEach(0..<min(gigsCount, 3), id: \.self) { _ in
                    Circle()
                        .fill(AppTheme.accent.gradient)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(.clear)
        .contentShape(Rectangle())
    }
}
