import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct ImageIdentifiable: Identifiable {
    let id = UUID()
    let images: [UIImage]
    let index: Int
}

struct GigDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var gig: Gig
    @State private var showingEdit = false
    @State private var imageToDeleteIndex: Int? = nil
    @State private var showDeleteDialog = false
    @State private var showingAllImages = false
    @StateObject private var contactManager = ContactManager()
    @State private var showingPicker = false
    @State private var showingNewContact = false

    @State private var selectedImage: ImageIdentifiable? = nil

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


                VStack(alignment: .leading, spacing: 12) {
                    Text("Imágenes")
                        .font(.title3.bold())

                    let imagesData = gig.images
                    let imagesUI = imagesData.compactMap { UIImage(data: $0) } // todas las UIImages

                    if imagesData.isEmpty {
                        Text("Sin imágenes")
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {

                                ForEach(Array(imagesData.prefix(5).enumerated()), id: \.offset) { index, data in

                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .onTapGesture {
                                                selectedImage = ImageIdentifiable(
                                                    images: imagesUI,
                                                    index: index
                                                )
                                            }
                                            .onLongPressGesture {
                                                imageToDeleteIndex = index
                                                showDeleteDialog = true
                                            }
                                    }
                                }

                                if imagesData.count > 5 {
                                    Button {
                                        showingAllImages = true
                                    } label: {
                                        VStack {
                                            Image(systemName: "ellipsis.circle")
                                                .font(.largeTitle)
                                                .foregroundColor(.purple)
                                            Text("Ver más")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                        }
                                        .frame(width: 120, height: 120)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }


                VStack(alignment: .leading, spacing:12) {
                    if let lat = gig.latitude, let lon = gig.longitude {
                        GigMapView(latitude: lat, longitude: lon)
                    } else {
                        Text("Sin ubicación definida")
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Contactos del evento")
                        .font(.title3.bold())

                    if gig.contacts.isEmpty {
                        Text("Sin contactos aún")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(gig.contacts) { c in
                            Button {
                                if let phone = c.phone,
                                   let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
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
                                    }
                                    .padding()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notas")
                        .font(.title3.bold())

                    if gig.notes.isEmpty {
                        Text("Sin notas")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(gig.notes)
                    }
                }
            }
            .padding()
        }

        .navigationTitle("Detalles del Bolo")
        .navigationBarTitleDisplayMode(.inline)

        .sheet(item: $selectedImage) { item in
            FullScreenImageViewer(images: item.images, initialIndex: item.index)
        }

        .sheet(isPresented: $showingAllImages) {
            GigAllImagesView(gig: gig)
        }

        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                GigFormView(gig: gig) { _ in try? context.save() }
            }
        }

        .sheet(isPresented: $showingPicker) {
            ContactPickerView(manager: contactManager)
        }

        .sheet(isPresented: $showingNewContact) {
            NewContactEditor()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button ("Editar"){
                    showingEdit = true
                }
            }
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
