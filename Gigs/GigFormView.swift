import SwiftUI
import SwiftData
import ContactsUI
import Contacts

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
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var showingLocationPicker = false
    
    @StateObject private var contactManager = ContactManager()
    @State private var showingPicker = false
    @State private var showingNewContact = false
    @State private var editingContact: GigContact?
    
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
        _latitude = State(initialValue: gig?.latitude)
        _longitude = State(initialValue: gig?.longitude)
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
            
            Section("Ubicación") {
                if let lat = latitude, let lon = longitude {
                    GigMapView(latitude: lat, longitude: lon)
                        .frame(height: 150)
                        .cornerRadius(12)
                } else {
                    Text("Sin ubicación seleccionada")
                        .foregroundStyle(.secondary)
                }
                
                Button("Elegir ubicación") {
                    showingLocationPicker = true
                }
            }
            
            Section("Contactos") {
                if let gig {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        if gig.contacts.isEmpty {
                            Text("Sin contactos aún")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(gig.contacts) { c in
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(c.name)
                                            .font(.headline)
                                            .foregroundColor(.purple)
                                        
                                        if let phone = c.phone {
                                            Label(phone, systemImage: "phone.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        if let email = c.email {
                                            Label(email, systemImage: "envelope.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Button {
                                                editingContact = c
                                            } label: {
                                                Image(systemName: "pencil.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.purple)
                                            }
                                            
                                            Button {
                                                gig.contacts.removeAll { $0.id == c.id }
                                            } label: {
                                                Image(systemName: "trash.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.top, 6)
                                    }
                                    .padding()
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Button("Seleccionar desde agenda") {
                                contactManager.requestAccess { granted in
                                    if granted { showingPicker = true }
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Button("Crear nuevo contacto") {
                                showingNewContact = true
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                } else {
                    Text("Guarda el bolo primero para añadir contactos.")
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
        .sheet(isPresented: $showingLocationPicker) {
            NavigationStack {
                LocationPickerView(
                    initialLatitude: latitude,
                    initialLongitude: longitude
                ) { lat, lon in
                    latitude = lat
                    longitude = lon
                }
            }
        }
        .onChange(of: contactManager.selectedContact) { contact in
            guard let c = contact else { return }
            guard let gig = gig else { return }
            
            // Evita duplicados
            if gig.contacts.contains(where: { $0.id == c.identifier }) {
                return
            }
            
            let newC = GigContact(
                id: c.identifier,
                name: CNContactFormatter.string(from: c, style: .fullName) ?? "Contacto",
                phone: c.phoneNumbers.first?.value.stringValue,
                email: (c.emailAddresses.first?.value as String?)
            )
            
            gig.contacts.append(newC)
        }
        
        .sheet(item: $editingContact) { contact in
            ContactEditView(contact: contact)
        }
        
        .sheet(isPresented: $showingNewContact) {
            NewContactEditor()
        }
        .sheet(isPresented: $showingPicker) {
            ContactPickerView(manager: contactManager)
        }
    }
    
    private var isValid: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !venue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func save() {
        let fee = Double(feeText.filter { $0.isNumber }) ?? 0

        if let gig = gig {
            // EDITAR EXISTENTE
            gig.date = date
            gig.eventName = eventName
            gig.venue = venue
            gig.fee = fee
            gig.durationMinutes = durationMinutes
            gig.style = style
            gig.notes = notes
            gig.latitude = latitude
            gig.longitude = longitude

            onSave(gig)

            NotificationManager.shared.scheduleNotification(for: gig)

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

            newGig.latitude = latitude
            newGig.longitude = longitude

            onSave(newGig)

            NotificationManager.shared.scheduleNotification(for: newGig)
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


struct ContactEditView: View {
    @Bindable var contact: GigContact
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Nombre", text: $contact.name)
            TextField("Teléfono", text: .init(
                get: { contact.phone ?? "" },
                set: { contact.phone = $0 }
            ))
            TextField("Email", text: .init(
                get: { contact.email ?? "" },
                set: { contact.email = $0 }
            ))
        }
        .navigationTitle("Editar contacto")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") { dismiss() }
            }
        }
    }
}

