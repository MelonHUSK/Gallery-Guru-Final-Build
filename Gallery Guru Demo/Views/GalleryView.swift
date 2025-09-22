import SwiftUI

struct GalleryView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(viewModel.folders.flatMap { $0.photos }) { photo in
                    NavigationLink(destination: PhotoDetailView(photo: Binding(
                        get: {
                            return photo
                        },
                        set: { newPhoto in
                            // Update the photo here if necessary
                        }), viewModel: viewModel)) {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                    }
                }
                .onDelete(perform: delete)
            }
            .padding()
        }
        .navigationTitle("Gallery")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let photo = viewModel.photos[index]
            if let galleryFolder = viewModel.folders.first(where: { $0.name == "Gallery"}) {
                viewModel.removePhoto(photo, from: galleryFolder)
            }
        }
    }
}
