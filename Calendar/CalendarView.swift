import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var context

    @StateObject private var vm = CalendarViewModel()
    @State private var showingNew = false
    @State private var editingGig: Gig?

    // Fuente única de verdad: todos los gigs ordenados por fecha
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
                        onSelectDay: { date in vm.selectedDate = date }
                    )

                    daySummary
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .navigationTitle("Calendario")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Label("Nuevo", systemImage: "plus")
                    }
                }
            }
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
                    GigFormView(gig: gig) { _ in
                        try? context.save()
                    }
                }
            }
        }
    }



    private var header: some View {
        HStack {
            Button { vm.prevMonth() } label: { Image(systemName: "chevron.left") }
            Spacer()
            Text(vm.currentMonth, format: .dateTime.month(.wide).year())
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            Spacer()
            Button { vm.nextMonth() } label: { Image(systemName: "chevron.right") }
        }
        .tint(AppTheme.accent)
        .padding(.top, 8)
    }

    private var daySummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(vm.selectedDate, format: .dateTime.day().month().year())
                    .font(.headline)
                Spacer()
                Button {
                    showingNew = true
                } label: {
                    Label("Añadir bolo", systemImage: "plus.circle.fill")
                }
                .tint(AppTheme.accent)
            }

            let gigsToday = gigsForDay(vm.selectedDate, gigs: gigs)

            if gigsToday.isEmpty {
                ContentUnavailableView(
                    "Sin bolos en este día",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Toca “Añadir bolo” para crear uno.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                List {
                    ForEach(gigsToday, id: \.id) { gig in
                        Button { editingGig = gig } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(gig.eventName.isEmpty ? "Sin título" : gig.eventName)
                                        .font(.headline)
                                    Text("\(gig.venue) · \(gig.date.formatted(date: .omitted, time: .shortened))")
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
                            let toDelete = gigsToday[i]
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
            let k = cal.startOfDay(for: g.date)
            dict[k, default: []].append(g)
        }
        return dict
    }

    private func gigsForDay(_ day: Date, gigs: [Gig]) -> [Gig] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
        return gigs.filter { $0.date >= start && $0.date < end }
    }
}

#Preview { CalendarView().preferredColorScheme(.dark) }
