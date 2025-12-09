import SwiftUI


struct NavigationOptionSheet: View {
    let latitude: Double
    let longitude: Double
    
    var body: some View {
        VStack(spacing: 16) { 
            Text("Abrir en…")
                .font(.title3.bold())
                .padding(.bottom, 8)
            
            ForEach(MapApp.allCases) { app in
                Button(app.name) {
                    app.open(latitude: latitude, longitude: longitude)
                }
                .buttonStyle(MapButtonStyle())
            }
        }
        .padding()
    }
}
