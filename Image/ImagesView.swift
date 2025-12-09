import SwiftUI
import PhotosUI

struct ImagesView: View {
    let gig: Gig
    let id: String

    @Environment(\.modelContext) private var context

    @State private var images: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []

    @State private var selectedIndex: Int = 0
    @State private var selectedImages: [UIImage] = []
    @State private var showingFullScreen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            ScrollView(.horizontal) {
                HStack {
                    ForEach(images.indices, id: \.self) { index in
                        let img = images[index]
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                            .onTapGesture {
                                selectedIndex = index
                                selectedImages = images
                                showingFullScreen = true
                            }
                    }
                }
            }

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                Label("Añadir imágenes", systemImage: "plus.circle")
            }
            .onChange(of: selectedItems) { _, items in
                for item in items {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImg = UIImage(data: data) {
                            saveImage(image: uiImg)
                            loadImages()
                        }
                    }
                }
            }
        }

        .sheet(isPresented: $showingFullScreen) {
            FullScreenImageViewer(images: selectedImages, initialIndex: selectedIndex)
        }

        .onAppear {
            loadImages()
        }
    }

    private func saveImage(image: UIImage) {
        Task.detached(priority: .userInitiated) {
            if let data = image.jpegData(compressionQuality: 0.85) {
                await MainActor.run {
                    gig.images.append(data)
                    try? context.save()
                }
            }
        }
    }

    private func loadImages() {
        images = gig.images.compactMap { UIImage(data: $0) }
    }
}
