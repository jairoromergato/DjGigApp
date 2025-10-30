import SwiftUI
import SwiftData

struct GigListView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Gig.date, order: .reverse)
    private var gigs: [Gig]
    
    @State private var showingNewGig = false
    @State private var editGig: Gig?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                Group {
                    if gigs.isEmpty {
                        EmptyStateView(
                            title: "Sin bolos",
                            message: "Pulsa + para registrar tu primer bolo."
                        )
                        .padding()
                    } else {
                        List {
                            ForEach(gigs) { gig in
                                Button { editGig = gig } label: {
                                    GigRow(gig: gig)
                                }
                                .listRowBackground(AppTheme.card)
                                .buttonStyle(.plain)
                            }
                            .onDelete(perform: delete)
                        }
                        .scrollContentBackground(.hidden) // para ver el bg azul oscuro
                    }
                }
            }
            .navigationTitle("Dj Gig")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewGig = true
                    } label: {
                        Image(systemName: "plus.circle.fill").imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingNewGig) {
                NavigationStack {
                    GigFormView { newGig in
                        context.insert(newGig)
                        try? context.save()
                    }
                }
            }
            .sheet(item: $editGig) { gig in
                NavigationStack {
                    GigFormView(gig: gig) { _ in
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


private func currencyString(for decimal: Decimal) -> String {
    let number = NSDecimalNumber(decimal: decimal)
    let nf = NumberFormatter()
    nf.numberStyle = .currency
    nf.currencyCode = "EUR"
    return nf.string(from: number) ?? "€\(number)"
}

private struct GigRow: View {
    let gig: Gig

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gig.eventName)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .bold()
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(gig.venue)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            // Derecha: importe + fecha + (opcional) duración
            VStack(alignment: .trailing, spacing: 4) {
                Text(currencyString(for: gig.feeEUR))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(gig.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("\(gig.durationMinutes) min")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 6)
    }
}


private struct EmptyStateView: View {
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.accent)
            Text(title).font(.title2).bold()
                .foregroundStyle(AppTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Crear primer bolo") { }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.card)
        )
    }
}

