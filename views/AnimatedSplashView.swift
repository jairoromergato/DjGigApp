import SwiftUI

struct AnimatedSplashView: View {
    let showText: Bool
    
    @State private var appearLogo = false
    @State private var flicker = false
    @State private var finalGlow = false
    
    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 18) {
                if showText {
                    NeonStaggeredText("DJ GIG APP")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .accessibilityLabel("DJ GIG APP")
                }
                    
            }
        }
    }
    
    private struct NeonFlickerText: View {
        let text: String
        let accent: Color
        let flicker: Bool
        let finalGlow: Bool
        
        init(_ text: String, accent: Color, flicker: Bool, finalGlow: Bool) {
            self.text = text
            self.accent = accent
            self.flicker = flicker
            self.finalGlow = finalGlow
        }
        
        var body: some View {
            let baseOpacity = finalGlow ? 1.0 : (flicker ? 0.25 : 0.95)
            let shadowRadius = finalGlow ? 18.0 : (flicker ? 2.0 : 10.0)
            let shadowOpacity = finalGlow ? 0.95 : (flicker ? 0.35 : 0.7)
            
            return Text(text)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .kerning(2)
                .foregroundStyle(accent)
                .opacity(baseOpacity)
                .shadow(color: accent.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 0)
                .overlay(
                    Text(text)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .kerning(2)
                        .foregroundStyle(accent.opacity(0.15))
                        .blur(radius: finalGlow ? 6 : 3)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
    }
}

struct NeonStaggeredText: View {
    let text: String
    private let baseSize: CGFloat = 40

    init(_ text: String) { self.text = text }

    var body: some View {
        let rows = text.split(separator: " ").map(String.init)
        VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, word in
                HStack(spacing: 8) {
                    ForEach(Array(word.enumerated()), id: \.offset) { i, ch in
                        NeonLetter(
                            String(ch),
                            delay: Double(rowIdx) * 0.25 + Double(i) * 0.5,
                            size: baseSize
                        )
                    }
                }
            }
        }
        .padding(.vertical, 12)
    }
}

private struct NeonLetter: View {
    let char: String
    let delay: Double
    let size: CGFloat

    @State private var on = false
    @State private var finalGlow = false

    private let neon = Color(hue: 0.91, saturation: 0.75, brightness: 1.0)
    private let halo = Color(hue: 0.62, saturation: 0.85, brightness: 1.0)

    init(_ char: String, delay: Double, size: CGFloat) {
        self.char = char
        self.delay = delay
        self.size = size
    }

    var body: some View {
        ZStack {
            Text(char)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(halo.opacity(finalGlow ? 0.45 : 0.25))
                .blur(radius: finalGlow ? 10 : 6)

            Text(char)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(neon)
                .opacity(on ? 1.0 : 0.15)
                .shadow(color: neon.opacity(on ? 0.95 : 0.3),
                        radius: on ? 16 : 4, x: 0, y: 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                let flickers = Int.random(in: 5...8)

                for n in 0..<flickers {
                    let tick = Double(n) * Double.random(in: 0.10...0.18)
                    DispatchQueue.main.asyncAfter(deadline: .now() + tick) {
                        withAnimation(.easeInOut(duration: 0.08)) {
                            on.toggle()
                        }
                    }
                }

                let finish = Double(flickers) * 0.20 + 0.35

                DispatchQueue.main.asyncAfter(deadline: .now() + finish) {
                    withAnimation(.easeInOut(duration: 0.12)) { on = true }
                    withAnimation(.easeInOut(duration: 0.35)) { finalGlow = true }
                }
            }
        }
    }
}
