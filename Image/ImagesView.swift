import SwiftUI
import PhotosUI

struct ImagesView: View {
    let gig: Gig
    let id: String
    
    @Environment(\.modelContext) private var context
    
    @State private var images: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(images.indices, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                    }
                }
            }
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                Label("Añadir imágenes", systemImage: "plus.circle")
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
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
        .onAppear {
            loadImages()
        }
    }
    
    private func saveImage(image: UIImage) {
        Task.detached(priority: .userInitiated) {
            if let data = image.jpegData(compressionQuality: 0.85) {
                await MainActor.run {
                    gig.images.append(data)
                }
            }
        }
    }
    
    private func loadImages() {
        images.removeAll()
        images = gig.images.compactMap { UIImage(data: $0) }
    }
}
