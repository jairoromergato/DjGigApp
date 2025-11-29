import SwiftUI

struct AllGigImagesView: View {
    var gigs: [Gig]
    var allImages: [Data] {
        gigs.flatMap { $0.images }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(allImages.enumerated()), id: \.offset) { _, imageData in
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .navigationTitle("Fotos")
    }
}
