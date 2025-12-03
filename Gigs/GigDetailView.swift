import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct GigDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var gig: Gig
    @State private var showingEdit = false

    @StateObject private var contactManager = ContactManager()
    @State private var showingPicker = false
    @State private var showingNewContact = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(gig.eventName.isEmpty ? "Sin título" : gig.eventName)
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)

                Group {
                    detailRow(title: "Fecha",
                              value: gig.date.formatted(date: .abbreviated, time: .shortened))

                    detailRow(title: "Lugar",
                              value: gig.venue.isEmpty ? "Sin lugar" : gig.venue)

                    detailRow(title: "Duración",
                              value: "\(gig.durationMinutes) min")

                    detailRow(title: "Estilo",
                              value: gig.style.isEmpty ? "Sin estilo" : gig.style)

                    detailRow(title: "Pago",
                              value: gig.fee.formatted(.currency(code: "EUR")))
                }

                if !gig.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notas")
                            .font(.title3.bold())
                        Text(gig.notes)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Imágenes")
                        .font(.title3.bold())
                    GigImagesGalleryView(gig: gig)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Contactos del evento")
                        .font(.title3.bold())

                    if gig.contacts.isEmpty {
                        Text("Sin contactos aún")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(gig.contacts) { c in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(c.name)
                                    .font(.headline)
                                if let phone = c.phone {
                                    Text(phone)
                                }
                                if let email = c.email {
                                    Text(email)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Button("Seleccionar desde agenda") {
                        contactManager.requestAccess { granted in
                            if granted { showingPicker = true }
                        }
                    }

                    Button("Crear nuevo contacto") {
                        showingNewContact = true
                    }
                }
                .padding(.top, 10)

            }
            .padding()
        }
        .navigationTitle("Detalles del Bolo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    showingEdit = true
                }
            }
        }

        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                GigFormView(gig: gig) { _ in
                    try? context.save()
                }
            }
        }

        .sheet(isPresented: $showingPicker) {
            ContactPickerView(manager: contactManager)
                .onChange(of: contactManager.selectedContact) { contact in
                    guard let c = contact else { return }

                    let newC = GigContact(
                        id: c.identifier,
                        name: CNContactFormatter.string(from: c, style: .fullName) ?? "Contacto",
                        phone: c.phoneNumbers.first?.value.stringValue,
                        email: (c.emailAddresses.first?.value as String?)
                    )

                    gig.contacts.append(newC)
                    try? context.save()
                }
        }

        .sheet(isPresented: $showingNewContact) {
            NewContactEditor()
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
