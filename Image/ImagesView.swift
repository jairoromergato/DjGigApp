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

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                Label("Añadir imágenes", systemImage: "photo.on.rectangle")
            }
            .onChange(of: selectedItems) { _, items in
                for item in items {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImg = UIImage(data: data) {

                            saveImageToDisk(image: uiImg)
                            loadImages()
                        }
                    }
                }
            }

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
        }
        .onAppear {
            loadImages()
        }
    }

    private func saveImageToDisk(image: UIImage) {
        let manager = FileManager.default

        guard let folder = getFolder() else { return }

        if !manager.fileExists(atPath: folder.path) {
            try? manager.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        let filename = folder.appendingPathComponent("\(UUID().uuidString).jpg")

        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: filename)
        }
    }

    private func loadImages() {
        images.removeAll()

        guard let folder = getFolder() else { return }

        if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "jpg" {
                if let uiImg = UIImage(contentsOfFile: file.path) {
                    images.append(uiImg)
                }
            }
        }
    }

    private func getFolder() -> URL? {
        let manager = FileManager.default
        return manager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(id)
    }
}
