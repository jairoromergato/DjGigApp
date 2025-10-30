import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.primaryGradient)
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct Chip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(AppTheme.card)
                    .overlay(
                        Capsule().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.accent.opacity(0.15), radius: 6, x: 0, y: 3)
            )
    }
}
