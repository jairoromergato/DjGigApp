import SwiftUI

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(AppTheme.bg)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(BackgroundModifier())
    }
}
