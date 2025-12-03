import SwiftUI
import MapKit

struct GigMapView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var region: MKCoordinateRegion
    @State private var showingSheet = false
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                annotationItems: [
                    MapPoint(latitude: latitude, longitude: longitude)
                ]
            ) { point in
                MapMarker(coordinate: point.coordinate, tint: .purple)
            }
            .frame(height: 220)
            .cornerRadius(16)
            
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture { showingSheet = true }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationOptionSheet(latitude: latitude, longitude: longitude)
                .presentationDetents([.height(280)])
        }
    }
}
