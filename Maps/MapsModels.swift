import Foundation
import UIKit

enum MapApp: CaseIterable, Identifiable {
    case apple
    case google
    case waze
    
    var id: String { name }
    
    var name: String {
        switch self {
        case .apple: return "Apple Maps"
        case .google: return "Google Maps"
        case .waze:  return "Waze"
        }
    }
    
    func url(latitude: Double, longitude: Double) -> URL? {
        switch self {
        case .apple:
            return URL(string: "maps://?daddr=\(latitude),\(longitude)&dirflg=d")
        case .google:
            return URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")
        case .waze:
            return URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")
        }
    }
    
    func webFallback(latitude: Double, longitude: Double) -> URL? {
        switch self {
        case .apple:
            return URL(string: "https://maps.apple.com/?daddr=\(latitude),\(longitude)")
        case .google:
            return URL(string: "https://maps.google.com/?q=\(latitude),\(longitude)")
        case .waze:
            return URL(string: "https://www.waze.com/ul?ll=\(latitude),\(longitude)&navigate=yes")
        }
    }
    
    func open(latitude: Double, longitude: Double) {
        if let appURL = url(latitude: latitude, longitude: longitude),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }

        if let fallback = webFallback(latitude: latitude, longitude: longitude) {
            UIApplication.shared.open(fallback)
        }
    }
}
