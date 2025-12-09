import SwiftUI

enum AppTheme {
    /// morado azulado
    static let accent        = Color(hex: 0x6C63FF) // morado azulado
    static let accentAlt     = Color(hex: 0x4F46E5) // índigo
    static let bg            = Color(hex: 0x0B1020) // azul muy oscuro
    static let card          = Color(hex: 0x131A2E) // azul oscuro suave
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let success       = Color(hex: 0x22C55E)
    static let warning       = Color(hex: 0xF59E0B)
    static let danger        = Color(hex: 0xEF4444)

    static let primaryGradient = LinearGradient(
        colors: [Color(hex: 0x3B82F6), Color(hex: 0x8B5CF6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
