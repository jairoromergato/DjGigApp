import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var lm = LocationManager()
    
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    
    let onSelect: (Double, Double) -> Void
    
    init(initialLatitude: Double?, initialLongitude: Double?, onSelect: @escaping (Double, Double) -> Void) {
        self.onSelect = onSelect
        
        let start = CLLocationCoordinate2D(
            latitude: initialLatitude ?? 40.4168,
            longitude: initialLongitude ?? -3.7038
        )
        
        _region = State(initialValue: MKCoordinateRegion(
            center: start,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
        
        _selectedCoordinate = State(initialValue: initialLatitude == nil ? nil : start)
    }
    
    var body: some View {
        VStack {
            
            HStack {
                TextField("Buscar dirección…", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Buscar") { searchAddress() }
                    .disabled(searchText.isEmpty)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $region, annotationItems: annotationItem) { p in
                MapMarker(coordinate: p.coordinate, tint: .purple)
            }
            .onTapGesture {
                selectedCoordinate = region.center
            }
            
            HStack {
                Button("Usar mi ubicación") {
                    lm.requestLocation()
                }
                .buttonStyle(.bordered)
            }
            
            Button("Guardar ubicación") {
                if let c = selectedCoordinate {
                    onSelect(c.latitude, c.longitude)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(selectedCoordinate == nil)
        }
        .navigationTitle("Elegir ubicación")
        .onChange(of: lm.userLocation) { newLocation in
            if let newLocation {
                selectedCoordinate = newLocation
                region.center = newLocation
            }
        }
    }
    
    private var annotationItem: [MapPoint] {
        guard let c = selectedCoordinate else { return [] }
        return [MapPoint(latitude: c.latitude, longitude: c.longitude)]
    }
    
    private func searchAddress() {
        CLGeocoder().geocodeAddressString(searchText) { places, error in
            guard let place = places?.first?.location else { return }
            let coord = place.coordinate
            
            selectedCoordinate = coord
            region.center = coord
        }
    }
}
