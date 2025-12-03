import Foundation
import MapKit

struct MapPoint: Identifiable {
    let id: UUID = UUID()
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
}

