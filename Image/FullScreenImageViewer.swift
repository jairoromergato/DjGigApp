import SwiftUI

struct FullScreenImageViewer: View {
    let images: [UIImage]
    let initialIndex: Int

    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

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
                        ScrollView([.vertical, .horizontal], showsIndicators: false) {
                            
                            Image(uiImage: images[i])
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                        }
                                )
                                .frame(width: proxy.size.width,
                                       height: proxy.size.height,
                                       alignment: .center)
                        }
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()

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
}
