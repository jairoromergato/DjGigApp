import SwiftUI

struct NeonFrame<Content: View>: View {
    let content: Content
    
    @State private var size: CGSize = .zero
    @State private var glow = false
    @State private var flicker = false
    @State private var spark = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(glow ? 1 : 0.4),
                        lineWidth: spark ? 4 : 2)
                .frame(width: size.width + 20,
                       height: size.height + 15)
                .shadow(color: .green.opacity(glow ? 1 : 0.45),
                        radius: glow ? 25 : 8)
                .shadow(color: .green.opacity(glow ? 0.7 : 0.2),
                        radius: glow ? 45 : 12)
                .opacity(flicker ? 0.4 : 1)
                .scaleEffect(spark ? 1.015 : 1)
                .animation(.easeInOut(duration: 0.15), value: spark)
                .animation(.easeInOut(duration: 0.25), value: flicker)
                .animation(.easeInOut(duration: 1.2).repeatForever(), value: glow)
        
            content
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.size = geo.size   
                        }
                        return .clear
                    }
                )
                .padding(.horizontal, 2)
                .padding(.vertical, 1)
        }
        .onAppear {
            glow = true
            flickerSequence()
            sparkLoop()
        }
    }
    
    private func flickerSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { flicker.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) { flicker.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) { flicker.toggle() }
    }
    
    private func sparkLoop() {
        let delay = Double.random(in: 1.4...3.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.07)) { spark = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                withAnimation(.easeOut(duration: 0.10)) { spark = false }
                sparkLoop()
            }
        }
    }
}




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
                    NeonFrame {
                        NeonStaggeredText("DJ GIG APP")
                    }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .accessibilityLabel("DJ GIG APP")
                }
            }
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
    @State private var glow = false

 
    private let neonMain = Color(hue: 0.91, saturation: 0.75, brightness: 1.0)


    private let neonGreen = Color(hue: 0.33, saturation: 0.85, brightness: 1.0)

    init(_ char: String, delay: Double, size: CGFloat) {
        self.char = char
        self.delay = delay
        self.size = size
    }

    var body: some View {
        ZStack {

  
            Text(char)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(neonGreen.opacity(glow ? 0.55 : 0.10))
                .blur(radius: glow ? 25 : 8)
                .scaleEffect(glow ? 1.05 : 1.0)

       
            Text(char)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(neonMain.opacity(glow ? 0.75 : 0.15))
                .blur(radius: glow ? 15 : 5)

     
            Text(char)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .foregroundStyle(neonMain)
                .opacity(on ? 1 : 0.2)
                .shadow(color: neonMain.opacity(on ? 1 : 0.4),
                        radius: on ? 20 : 6,
                        x: 0, y: 0)
        }
        .onAppear {

            // Delay natural del stagger para que no aparezcan todas a la vez
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                // --- Parpadeo inicial del tubo (como neón real encendiéndose) ---
                withAnimation(.easeInOut(duration: 0.10)) { on = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.easeInOut(duration: 0.08)) { on = false }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    withAnimation(.easeInOut(duration: 0.12)) { on = true }
                }

                // --- Glow final, verde + violeta ---
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                    withAnimation(.easeInOut(duration: 0.50)) {
                        glow = true
                        on = true
                    }
                }
            }
        }
    }
}
