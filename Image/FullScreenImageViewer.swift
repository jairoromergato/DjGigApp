import SwiftUI

struct FullScreenImageViewer: View {
    let images: [UIImage]
    let initialIndex: Int

    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero

    init(images: [UIImage], initialIndex: Int) {
        self.images = images
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { i in
                    GeometryReader { proxy in
                        let size = proxy.size

                        Image(uiImage: images[i])
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)
                            .scaleEffect(scale)
                            .offset(offset)
                            .animation(.easeInOut(duration: 0.2), value: scale)
                            .animation(.easeInOut(duration: 0.2), value: offset)
                            
                            .gesture(
                                TapGesture(count: 2)
                                    .onEnded { handleDoubleTap() }
                            )

                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        scale = max(1, newScale)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        if scale == 1 {
                                            offset = .zero
                                        }
                                    }
                            )

                            .simultaneousGesture(
                                scale > 1 ? dragGesture() : nil
                            )
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            .gesture(
                scale > 1 ? DragGesture() : nil
            )

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }

    private func handleDoubleTap() {
        if scale == 1 {
            scale = 1.5
            lastScale = 1.5
        } else {
            scale = 1
            lastScale = 1
            offset = .zero
        }
    }


    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = value.translation
            }
            .onEnded { _ in
                if scale == 1 {
                    offset = .zero
                }
            }
    }
}
