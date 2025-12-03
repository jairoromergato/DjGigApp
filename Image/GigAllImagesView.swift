import SwiftUI
import SwiftData

struct GigAllImagesView: View {
    let gig: Gig?
    @State var images: [Data] = []
    @Environment(\.modelContext) var context
    
    // 2 columnas
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(images.enumerated()), id: \.offset) { _, imageData in
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Fotos del bolo")
        .navigationBarTitleDisplayMode(.inline)
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
