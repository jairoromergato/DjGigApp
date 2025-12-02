import SwiftUI
import SwiftData

struct GigDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var gig: Gig
    @State private var showingEdit = false
    @State private var imageToDeleteIndex: Int? = nil
    @State private var showDeleteDialog = false
    @State private var showingAllImages = false

    
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
                    
                    let images = gig.images
                    
                    if images.isEmpty {
                        Text("Sin imágenes")
                            .foregroundStyle(.secondary)
                    } else {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                ForEach(Array(images.prefix(5).enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                            .onLongPressGesture {
                                                imageToDeleteIndex = index
                                                showDeleteDialog = true
                                            }
                                    }
                                }
                                
                                if images.count > 5 {
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
                    Text("Ubicacion")
                        .font(.title3.bold())
                    if let lat = gig.latitude, let lon = gig.longitude {
                        VStack(alignment: .leading, spacing: 12) {
                            GigMapView(latitude: lat, longitude: lon)
                        }
                    } else {
                        Text("Sin ubicación definida")
                            .foregroundStyle(.secondary)
                    }
                }
                
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingAllImages) {
            AllGigImagesView(images: gig.images)
        }
        
        .fullScreenCover(isPresented: $showingEdit) {
            NavigationStack {
                GigFormView(gig: gig) { _ in
                    try? context.save()
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
