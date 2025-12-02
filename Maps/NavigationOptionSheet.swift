import SwiftUI

struct NavigationOptionSheet: View {
    let latitude: Double
    let longitude: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Abrir en…")
                .font(.title3.bold())
            
            Button("Apple Maps") {
                openAppleMaps()
            }.buttonStyle(.borderedProminent)
            
            Button("Google Maps") {
                openGoogleMaps()
            }.buttonStyle(.bordered)
            
            Button("Waze") {
                openWaze()
            }.buttonStyle(.bordered)
        }
        .padding()
    }
}

private extension NavigationOptionSheet {
    func openAppleMaps() {
        let url = URL(string: "maps://?daddr=\(latitude),\(longitude)&dirflg=d")!
        UIApplication.shared.open(url)
    }
    
    func openGoogleMaps() {
        let url = URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let web = URL(string: "https://maps.google.com/?q=\(latitude),\(longitude)")!
            UIApplication.shared.open(web)
        }
    }
    
    func openWaze() {
        let url = URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let web = URL(string: "https://www.waze.com/ul?ll=\(latitude),\(longitude)&navigate=yes")!
            UIApplication.shared.open(web)
        }
    }
}
