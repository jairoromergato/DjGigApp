import SwiftUI

struct TrackSearchList: View {
    let query: String
    let selected: [Track]
    let onSelectExisting: (Track) -> Void
    let onCreateNew: (String, String?) -> Void

    @Binding var results: [Track]

    var body: some View {
        VStack(spacing: 0) {
            if results.isEmpty && !query.trimmed.isEmpty {
                Button {
                    let (title, artist) = parseInput(query)
                    onCreateNew(title, artist)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Crear “\(query)” como track")
                        Spacer()
                    }
                    .padding(12)
                }
                .buttonStyle(.plain)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                List(results, id: \.id) { track in
                    Button {
                        onSelectExisting(track)
                    } label: {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundStyle(AppTheme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .foregroundStyle(AppTheme.textPrimary)
                                if !track.artist.trimmed.isEmpty {
                                    Text(track.artist)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                            Spacer()
                            if selected.contains(where: { $0.id == track.id }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .accessibilityLabel("Seleccionado")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(AppTheme.card)
                }
                .listStyle(.plain)
                .frame(maxHeight: 240)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(AppTheme.card)
                )
            }
        }
    }

    // MARK: - Parseo "Título — Artista" o "Título - Artista"
    func parseInput(_ input: String) -> (String, String?) {
        let separators: [String] = [" — ", " - ", "–", "—", "-"]
        for sep in separators {
            if let r = input.range(of: sep) {
                let left  = input[..<r.lowerBound]
                let right = input[r.upperBound...]
                let title = String(left).trimmed
                let artist = String(right).trimmed
                return (title, artist.isEmpty ? nil : artist)
            }
        }
        return (input.trimmed, nil)
    }
}

// ⬇️ Esta extensión debe estar a NIVEL DE ARCHIVO.
// Si ya tienes `trimmed` en otro archivo (p.ej. String+Trimmed.swift), ELIMINA esta para evitar duplicados.
extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
