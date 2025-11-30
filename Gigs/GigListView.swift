import SwiftUI
import SwiftData

struct GigListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Gig.date, order: .reverse) private var gigs: [Gig]
    @State private var showingNew = false
    @State private var editingGig: Gig?

    var body: some View {
        NavigationStack {
            Group {
                if gigs.isEmpty {
                    ContentUnavailableView("Sin bolos aún",
                                           systemImage: "music.mic",
                                           description: Text("Toca “Nuevo bolo” para registrar el primero."))
                } else {
                    List {
                        ForEach(gigs) { gig in
                            NavigationLink {
                                GigDetailView(gig: gig)
                            } label: {

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(gig.eventName.isEmpty ? "Sin título" : gig.eventName)
                                            .font(.headline)
                                        Text("\(gig.venue) · \(gig.date.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("€ \(Int(gig.fee))")
                                        Text("\(gig.durationMinutes) min")
                                            .foregroundStyle(.secondary)
                                            .font(.footnote)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Bolos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Label("Nuevo bolo", systemImage: "plus")
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
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(gigs[index])
        }
        try? context.save()
    }
}
