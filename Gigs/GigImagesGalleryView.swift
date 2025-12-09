import SwiftUI

struct GigImagesGalleryView: View {
    let gig: Gig
    @State private var images: [UIImage] = []
    @State private var isLoadingImages = false

    @State private var selectedIndex: Int = 0
    @State private var showingFullScreen = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            if images.isEmpty {
                if isLoadingImages {
                    ProgressView()
                } else {
                    Text("Sin imágenes")
                        .foregroundStyle(.secondary)
                }
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(images.indices, id: \.self) { index in
                        let img = images[index]

                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                            .onTapGesture {
                                selectedIndex = index
                                showingFullScreen = true
                            }
                    }
                }
            }
        }

        .fullScreenCover(isPresented: $showingFullScreen) {
            FullScreenImageViewer(
                images: images,
                initialIndex: selectedIndex
            )
        }

        .onAppear {
            loadImages()
        }
    }

    private func loadImages() {
        guard images.isEmpty else { return }
        isLoadingImages = true

        Task {
            let imgs = gig.images.compactMap(UIImage.init)
            await MainActor.run {
                self.images = imgs
                isLoadingImages = false
            }
        }
    }
}
