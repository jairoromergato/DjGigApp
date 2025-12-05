import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var context

    @StateObject private var vm = CalendarViewModel()
    @State private var showingNew = false
    @State private var editingGig: Gig?

    @Query(sort: \Gig.date) private var gigs: [Gig]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 16) {
                    header

                    MonthGrid(
                        month: vm.currentMonth,
                        gigsByDay: groupGigsByDay(gigs),
                        onSelectDay: { date in
                            vm.selectedDate = date
                        }
                    )

                    daySummary
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .navigationTitle("Calendario")

            .sheet(isPresented: $showingNew) {
                NavigationStack {
                    GigFormView { newGig in
                        context.insert(newGig)
                        try? context.save()
                    }
                }
            }

            .sheet(item: $editingGig) { gig in
                NavigationStack {
                    GigFormView(gig: gig) { updatedGig in
                        try? context.save()
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { vm.prevMonth() } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(vm.currentMonth, format: .dateTime.month(.wide).year())
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.accent)

            Spacer()

            Button { vm.nextMonth() } label: {
                Image(systemName: "chevron.right")
            }
        }
        .tint(AppTheme.accent)
        .padding(.top, 8)
    }

    private var daySummary: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(vm.selectedDate, format: .dateTime.month().year())
                    .font(.headline)

                Spacer()

                Button {
                    showingNew = true
                } label: {
                    Label("Añadir bolo", systemImage: "plus.circle.fill")
                }
                .tint(AppTheme.accent)
            }

            let gigsThisMonth = gigsForMonth(vm.selectedDate, gigs: gigs)

            if gigsThisMonth.isEmpty {
                ContentUnavailableView(
                    "Sin bolos este mes",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Toca “Añadir bolo” para crear uno.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            } else {

                List {
                    ForEach(gigsThisMonth, id: \.id) { gig in
                        Button { editingGig = gig } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(gig.eventName.isEmpty ? "Sin título" : gig.eventName)
                                        .font(.headline)

                                    Text("\(gig.venue) · \(gig.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(gig.fee, format: .currency(code: "EUR"))
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete { idx in
                        for i in idx {
                            let toDelete = gigsThisMonth[i]
                            context.delete(toDelete)
                        }
                        try? context.save()
                    }
                }
                .listStyle(.insetGrouped)
                .frame(maxHeight: 260)
            }
        }
        .padding(.top, 8)
    }

    private func groupGigsByDay(_ gigs: [Gig]) -> [Date: [Gig]] {
        var dict: [Date: [Gig]] = [:]
        let cal = Calendar.current

        for g in gigs {
            let dayKey = cal.startOfDay(for: g.date)
            dict[dayKey, default: []].append(g)
        }
        return dict
    }

    private func gigsForMonth(_ date: Date, gigs: [Gig]) -> [Gig] {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let range = cal.range(of: .day, in: .month, for: date)!
        let endOfMonth = cal.date(byAdding: .day, value: range.count, to: startOfMonth)!
        return gigs.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
    }
}

#Preview {
    CalendarView().preferredColorScheme(.dark)
}
