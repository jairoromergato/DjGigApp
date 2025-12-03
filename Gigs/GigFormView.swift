import SwiftUI
import SwiftData

struct GigFormView: View {
    var gig: Gig?
    var onSave: (Gig) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var eventName: String
    @State private var venue: String
    @State private var feeText: String
    @State private var durationMinutes: Int
    @State private var style: String
    @State private var notes: String

    init(gig: Gig? = nil, onSave: @escaping (Gig) -> Void) {
        self.gig = gig
        self.onSave = onSave
        _date = State(initialValue: gig?.date ?? Date())
        _eventName = State(initialValue: gig?.eventName ?? "")
        _venue = State(initialValue: gig?.venue ?? "")
        _feeText = State(initialValue: gig.map { String(Int($0.fee)) } ?? "")
        _durationMinutes = State(initialValue: gig?.durationMinutes ?? 0)
        _style = State(initialValue: gig?.style ?? "")
        _notes = State(initialValue: gig?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Detalles") {
                DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Evento / Fiesta", text: $eventName)
                TextField("Sala / Lugar", text: $venue)
                TextField("Estilo (Techno, House…)", text: $style)
            }

            Section("Condiciones") {
                TextField("Honorarios (€)", text: $feeText)
                    .keyboardType(.numberPad)

                Section("Duración") {
                    DurationPickerInline(minutes: $durationMinutes)

                    HStack {
                        Text("Seleccionado")
                        Spacer()
                        Text(durationText(durationMinutes))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Imágenes") {
                if let gig {
                    ImagesView(gig: gig, id: gig.id.uuidString)
                } else {
                    Text("Guarda el bolo primero para añadir imágenes.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Notas") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(gig == nil ? "Nuevo bolo" : "Editar bolo")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") { save() }
                    .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !venue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let fee = Double(feeText.filter { $0.isNumber }) ?? 0

        if let gig = gig {
            gig.date = date
            gig.eventName = eventName
            gig.venue = venue
            gig.fee = fee
            gig.durationMinutes = durationMinutes
            gig.style = style
            gig.notes = notes
            onSave(gig)

        } else {
            let newGig = Gig(
                date: date,
                eventName: eventName,
                venue: venue,
                fee: fee,
                durationMinutes: durationMinutes,
                style: style,
                notes: notes
            )
            onSave(newGig)
        }

        dismiss()
    }
}

private func durationText(_ minutes: Int) -> String {
    guard minutes > 0 else { return "0 min" }
    let h = minutes / 60
    let m = minutes % 60
    switch (h, m) {
    case (0, _): return "\(m) min"
    case (_, 0): return "\(h) h"
    default:     return "\(h) h \(m) min"
    }
}
