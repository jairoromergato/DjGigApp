import SwiftUI
import SwiftData

struct GigAllImagesView: View {
    let gig: Gig?
    @State var images: [Data] = []
    @Environment(\.modelContext) var context

    // 🔥 visor
    // Wrapper to make UIImage identifiable for fullScreenCover(item:)
    private struct IdentifiedImage: Identifiable, Equatable {
        let id = UUID()
        let image: UIImage
        let index: Int
    }

    @State private var selectedImage: IdentifiedImage? = nil
//    @State private var showingFullScreen = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageData in
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(12)
                            .onTapGesture {
                                selectedImage = IdentifiedImage(image: uiImage, index: index)
//                                showingFullScreen = true
                            }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Fotos del bolo")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedImage) { identified in
            let uiImages: [UIImage] = images.compactMap { UIImage(data: $0) }
            FullScreenImageViewer(images: uiImages, initialIndex: identified.index)
        }
        .task {
            if let gig {
                images = gig.images
            } else {
                loadAllImages()
            }
        }
    }

    func loadAllImages() {
        let allGigs = (try? context.fetch(FetchDescriptor<Gig>())) ?? []
        images = allGigs.flatMap(\.images)
    }
}
