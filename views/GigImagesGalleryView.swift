import SwiftUI

struct GigImagesGalleryView: View {
    let gigID: String
    @State private var images: [UIImage] = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if images.isEmpty {
                Text("Sin imágenes")
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 110)
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

    private func loadImages() {
        images.removeAll()

        let manager = FileManager.default
        guard let folder = manager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(gigID) else { return }

        if let files = try? manager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension.lowercased() == "jpg" {
                if let img = UIImage(contentsOfFile: file.path) {
                    images.append(img)
                }
            }
        }
    }
}
