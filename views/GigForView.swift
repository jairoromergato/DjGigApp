import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct GigFormView: View {
    var gig: Gig?
    var onSave: (Gig) -> Void
    @Environment(\.modelContext) private var context

    @State private var date: Date
    @State private var eventName: String
    @State private var venue: String
    @State private var feeText: String
    @State private var durationMinutes: Int
    @State private var style: String
    @State private var notes: String

    // Duración (modal centrado)
    @State private var showCenteredDuration = false

    // Tracks
    @State private var searchText: String = ""
    @State private var selectedTracks: [Track] = []
    @State private var searchResults: [Track] = []

    // Import Rekordbox
    @State private var showFileImporter = false
    @State private var importMessage: String? = nil

    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var context

    // MARK: - Init
    init(gig: Gig? = nil, onSave: @escaping (Gig) -> Void) {
        self.gig = gig
        self.onSave = onSave

        _date = State(initialValue: gig?.date ?? Date())
        _eventName = State(initialValue: gig?.eventName ?? "")
        _venue = State(initialValue: gig?.venue ?? "")
        _feeText = State(initialValue: gig.map { "\($0.feeEUR)" } ?? "")
        _durationMinutes = State(initialValue: gig?.durationMinutes ?? 60)
        _style = State(initialValue: gig?.style ?? "")
        _notes = State(initialValue: gig?.notes ?? "")
        _selectedTracks = State(initialValue: gig?.tracks ?? [])
    }

    // MARK: - Body
    var body: some View {
        Form {
            // --- Datos del bolo ---
            Section("Bolo") {
                TextField("Nombre de la fiesta", text: $eventName)
                TextField("Sala / venue", text: $venue)
                DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Estilo (ej. Tech House)", text: $style)
            }

            // --- Duración ---
            Section("Duración") {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showCenteredDuration = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(AppTheme.accent)
                        Text("Duración")
                        Spacer()
                        Text(durationString(durationMinutes))
                            .foregroundStyle(AppTheme.textSecondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }

            // --- Tracks (chips + buscador + importación) ---
            Section("Tracks") {
                // Chips seleccionados
                if selectedTracks.isEmpty {
                    Text("Aún no has añadido tracks.")
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    FlexibleChipWrap(selectedTracks) { track in
                        TrackChip(title: track.title, artist: track.artist) {
                            removeTrack(track)
                        }
                        .padding(.vertical, 2)
                    }
                }

                // Buscador + resultados
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(AppTheme.textSecondary)
                        TextField("Buscar track… (título o artista)", text: $searchText)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.card)
                    )

                    TrackSearchList(
                        query: searchText,
                        selected: selectedTracks,
                        onSelectExisting: { track in
                            addTrack(track)
                        },
                        onCreateNew: { title, artist in
                            createOrReuseTrack(title: title, artist: artist)
                        },
                        results: $searchResults
                    )
                    .frame(minHeight: 80)
                }
                .modifier(OnChangeCompat(searchText) { newValue in
                    refreshResults(matching: newValue)
                })
                .onAppear {
                    refreshResults(matching: "")
                }

                // Import Rekordbox (CSV)
                Button {
                    showFileImporter = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Importar desde Rekordbox (CSV)")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }

            // --- Detalles ---
            Section("Detalles") {
                TextField("Caché (€)", text: $feeText)
                    .keyboardType(.decimalPad)
                TextField("Notas", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle(gig == nil ? "Nuevo bolo" : "Editar bolo")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(AppTheme.textSecondary)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar", action: save)
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!isValid)
            }
        }
        // Modal centrado de duración
        .overlay {
            if showCenteredDuration {
                CenteredDurationModal(
                    minutes: $durationMinutes,
                    onCancel: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            showCenteredDuration = false
                        }
                    },
                    onDone: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            showCenteredDuration = false
                        }
                    }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(10)
            }
        }
        // File importer + alert
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first { handleImport(url: url) }
            case .failure(let error):
                importMessage = "No se pudo abrir el archivo: \(error.localizedDescription)"
            }
        }
        .alert(importMessage ?? "", isPresented: Binding(
            get: { importMessage != nil },
            set: { if !$0 { importMessage = nil } }
        )) {
            Button("OK", role: .cancel) { importMessage = nil }
        }
    }

    // MARK: - Validación
    private var isValid: Bool {
        guard !eventName.trimmed.isEmpty else { return false }
        guard !venue.trimmed.isEmpty else { return false }
        guard durationMinutes >= 0 else { return false }
        guard let fee = decimal(from: feeText), fee >= 0 else { return false }
        return true
    }

    // MARK: - Guardar
    private func save() {
        guard let fee = decimal(from: feeText) else { return }

        if let gig {
            gig.date = date
            gig.eventName = eventName.trimmed
            gig.venue = venue.trimmed
            gig.feeEUR = fee
            gig.durationMinutes = durationMinutes
            gig.style = style
            gig.notes = notes
            gig.tracks = selectedTracks
            onSave(gig)
        } else {
            let newGig = Gig(
                eventName: eventName.trimmed,
                date: date,
                venue: venue.trimmed,
                feeEUR: fee,
                durationMinutes: durationMinutes,
                style: style,
                notes: notes
            )
            newGig.tracks = selectedTracks
            onSave(newGig)
        }
        dismiss()
    }

    // MARK: - Tracks helpers
    private func addTrack(_ track: Track) {
        if !selectedTracks.contains(where: { $0.id == track.id }) {
            selectedTracks.append(track)
        }
    }

    private func removeTrack(_ track: Track) {
        selectedTracks.removeAll { $0.id == track.id }
    }

    private func createOrReuseTrack(title: String, artist: String?) {
        if let existing = findTrack(title: title, artist: artist) {
            addTrack(existing)
        } else {
            let t = Track(title: title.trimmed, artist: (artist ?? "").trimmed)
            context.insert(t)
            addTrack(t)
        }
        refreshResults(matching: searchText)
    }

    // EXACTA título+artista (para evitar duplicados al crear)
    private func findTrack(title: String, artist: String?) -> Track? {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = (artist ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        var desc = FetchDescriptor<Track>()
        desc.fetchLimit = 300
        desc.sortBy = [SortDescriptor(\.title, order: .forward)]

        guard let all = try? context.fetch(desc) else { return nil }
        return all.first(where: { tr in
            tr.title.compare(t, options: .caseInsensitive) == .orderedSame &&
            tr.artist.compare(a, options: .caseInsensitive) == .orderedSame
        })
    }

    // BÚSQUEDA contains (case-insensitive), con límite
    private func refreshResults(matching text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)

        var desc = FetchDescriptor<Track>()
        desc.sortBy = [SortDescriptor(\.title, order: .forward)]
        desc.fetchLimit = 500   // ajusta si tienes muchos

        guard let fetched = try? context.fetch(desc) else {
            self.searchResults = []
            return
        }

        if q.isEmpty {
            self.searchResults = Array(fetched.prefix(10))
        } else {
            self.searchResults = fetched.filter { tr in
                tr.title.range(of: q, options: .caseInsensitive) != nil ||
                tr.artist.range(of: q, options: .caseInsensitive) != nil
            }
            .prefix(20)
            .map { $0 }
        }
    }

    // MARK: - Import Rekordbox
    private func handleImport(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let imported = try RekordboxImporter.parseCSV(data)
            var created = 0
            var reused  = 0

            for it in imported {
                if let existing = findTrack(title: it.title, artist: it.artist) {
                    reused += 1
                    addTrack(existing)
                } else {
                    let t = Track(title: it.title.trimmed, artist: it.artist.trimmed)
                    context.insert(t)
                    addTrack(t)
                    created += 1
                }
            }
            importMessage = "Importación completada: \(created) creados, \(reused) reutilizados."
            refreshResults(matching: searchText)
        } catch {
            importMessage = "Fallo al importar: \(error.localizedDescription)"
        }
    }

    // MARK: - Utilidades
    private func decimal(from text: String) -> Decimal? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func durationString(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        switch (h, m) {
        case (0, _): return "\(m) min"
        case (_, 0): return "\(h) h"
        default:     return "\(h) h \(m) min"
        }
    }
    private func refreshResults(matching text: String, context: ModelContext) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Trae un subconjunto y filtra en memoria
        var desc = FetchDescriptor<Track>()
        desc.sortBy = [SortDescriptor(\.title, order: .forward)]
        desc.fetchLimit = 300  // ajusta si tienes muchos

        if let fetched = try? context.fetch(desc) {
            if q.isEmpty {
                self.searchResults = Array(fetched.prefix(10))
            } else {
                self.searchResults = fetched.filter { tr in
                    tr.title.range(of: q, options: .caseInsensitive) != nil ||
                    tr.artist.range(of: q, options: .caseInsensitive) != nil
                }
                .prefix(20)
                .map { $0 }
            }
        }
    }


}

//private extension String {
//    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
//}

// MARK: - FlexibleChipWrap
/// Distribuye chips en múltiples líneas automáticamente.
struct FlexibleChipWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    private let data: Data
    private let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    @Environment(\.modelContext) private var context
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(data) { item in
                    content(item)
                        .padding(.trailing, 8)
                        .alignmentGuide(.leading) { d in
                            if width + d.width > geometry.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            width += d.width
                            return result
                        }
                        .alignmentGuide(.top) { d in
                            let result = height
                            return result
                        }
                }
            }
        }
        .frame(minHeight: 0, alignment: .topLeading)
        .padding(.vertical, 4)
    }
}

// MARK: - OnChangeCompat (iOS 16/17)
private struct OnChangeCompat<Value: Equatable>: ViewModifier {
    let value: Value
    let action: (Value) -> Void

    init(_ value: Value, action: @escaping (Value) -> Void) {
        self.value = value
        self.action = action
    }

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            content.onChange(of: value) { newValue in action(newValue) }
        }
    }
}
private func findTrack(title: String, artist: String?, context: ModelContext) -> Track? {
    // Trae candidatos razonables y filtra en memoria con case-insensitive
    var desc = FetchDescriptor<Track>()
    desc.fetchLimit = 200
    // (opcional) orden para consistencia
    desc.sortBy = [SortDescriptor(\.title, order: .forward)]

    let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
    let a = (artist ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

    guard let all = try? context.fetch(desc) else { return nil }
    return all.first(where: { tr in
        tr.title.compare(t, options: .caseInsensitive) == .orderedSame &&
        tr.artist.compare(a, options: .caseInsensitive) == .orderedSame
    })
}
