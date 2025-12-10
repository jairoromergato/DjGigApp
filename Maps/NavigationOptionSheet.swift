import SwiftUI

struct NavigationOptionSheet: View {
    let latitude: Double
    let longitude: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Abrir en…")
                .font(.title3.bold())
                .padding(.top, 6)
            
            ForEach(MapApp.allCases) { app in
                Button {
                    app.open(latitude: latitude, longitude: longitude)
                } label: {
                    Label {
                        Text(app.name)
                            .font(.headline)
                            .foregroundColor(.white)
                    } icon: {
                        Image(app.iconMaps)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                }
                .buttonStyle(MapButtonStyle())
            }
        }
        .padding()
    }
}
