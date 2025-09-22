import SwiftUI

struct TagPickerView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @Binding var photo: Photo // Use @Binding to allow updates

    @State private var newTagName: String = ""
    @State private var availableTags: [Tag] = []

    // Dummy state variable to force refresh
    @State private var forceRefresh: Bool = false

    // Environment variable to control dismissal
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("New Tag Name", text: $newTagName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Add Tag") {
                guard !newTagName.isEmpty else { return }
                let newTag = Tag(name: newTagName)
                availableTags.append(newTag)
                viewModel.addTag(newTag) // Add the new tag to the viewModel or persist it globally
                newTagName = "" // Clear input
                // Trigger UI update
                forceRefresh.toggle()
            }
            .padding()

            List {
                ForEach(availableTags) { tag in
                    HStack {
                        Text(tag.name)
                        Spacer()
                        Button(action: {
                            if let index = photo.tags.firstIndex(where: { $0.id == tag.id }) {
                                // Remove the tag if already added
                                photo.tags.remove(at: index)
                            } else {
                                // Add the tag if not already added
                                photo.tags.append(tag)
                            }
                            // Trigger UI update
                            forceRefresh.toggle()
                        }) {
                            Circle()
                                .fill(photo.tags.contains(where: { $0.id == tag.id }) ? Color.blue : Color.gray)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .navigationTitle("Assign Tags")
        // Initialize available tags when the view appears
        .onAppear {
            availableTags = viewModel.getAllTags() // Pull tags from the viewModel or globally stored tags
        }
        // Use forceRefresh to trigger UI update
        .id(forceRefresh) // This ensures the view refreshes each time forceRefresh is toggled
    }
}
