import SwiftUI

struct MonthGrid: View {
    let month: Date
    let gigsByDay: [Date: [Gig]]
    let onSelectDay: (Date) -> Void

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            // Nombres de los días
            HStack {
                ForEach(cal.shortWeekdaySymbols, id: \.self) { s in
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
        let firstWeekday = cal.component(.weekday, from: start) // 1..7
        var days: [Date] = []

        // Relleno anterior
        if let prev = cal.date(byAdding: .day, value: -(firstWeekday - 1), to: start) {
            for i in 0..<(firstWeekday - 1) {
                days.append(cal.date(byAdding: .day, value: i, to: prev)!)
            }
        }

        // Días del mes
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: start)!)
        }

        // Relleno posterior hasta completar 6 filas * 7 cols si quieres (opcional)
        while days.count % 7 != 0 { days.append(cal.date(byAdding: .day, value: 1, to: days.last!)!) }

        return days
    }
}

private struct DayCell: View {
    let date: Date
    let isInMonth: Bool
    let gigsCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isInMonth ? .primary : .secondary)

            // puntos de eventos
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
