import SwiftUI
import SwiftData

struct GigDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var gig: Gig
    @State private var showingEdit = false
    
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
                    GigImagesGalleryView(gig: gig)
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
