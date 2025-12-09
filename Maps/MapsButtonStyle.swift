import SwiftUI

struct MapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple) 
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
