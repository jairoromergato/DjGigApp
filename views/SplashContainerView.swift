import SwiftUI

struct SplashContainerView: View {
    @State private var phase: Phase = .photo

    enum Phase { case photo, text, done }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            switch phase {
            case .photo:
                AnimatedSplashView(showText: false)
                    .transition(.opacity)
            case .text:
                AnimatedSplashView(showText: true)
                    .transition(.opacity)
            case .done:
                HomeView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.4)) { phase = .text }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 0.5)) { phase = .done }
            }

            }
        }
    }

#Preview { SplashContainerView().preferredColorScheme(.dark) }
