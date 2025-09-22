import SwiftUI

struct TagSelectionView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var selectedTag: Tag? // Track the selected tag

    var body: some View {
        List {
            ForEach(viewModel.getAllTags()) { tag in
                Button(action: {
                    selectedTag = tag
                }) {
                    HStack {
                        Text(tag.name)
                        Spacer()
                        if selectedTag?.id == tag.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Tag")
        .navigationBarItems(trailing: NavigationLink(destination: PhotosWithTagView(viewModel: viewModel, tag: selectedTag)) {
            Text("View Photos")
                .fontWeight(.bold)
                .disabled(selectedTag == nil) // Disable if no tag is selected
        })
    }
}
