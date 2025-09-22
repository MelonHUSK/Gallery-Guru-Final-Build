import SwiftUI

struct PhotosWithTagView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    var tag: Tag? // The selected tag

    var body: some View {
        VStack {
            if let tag = tag {
                Text("Photos with tag: \(tag.name)")
                    .font(.title)
                    .padding()

                // Display the filtered photos
                let photosWithTag = viewModel.getPhotosByTag(for: tag)
                if photosWithTag.isEmpty {
                    Text("No photos found for this tag.")
                        .foregroundColor(.gray)
                } else {
                    List(photosWithTag) { photo in
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                            .padding(5)
                    }
                }
            } else {
                Text("Please select a tag.")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Photos with Tag")
    }
}
