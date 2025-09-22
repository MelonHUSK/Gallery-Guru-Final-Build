import SwiftUI

struct PhotoSearchView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var searchQuery: String = ""
    @State private var searchResults: [Photo] = []

    var body: some View {
        VStack {
            TextField("Search by title or description", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                searchResults = viewModel.searchPhotosByDesc(query: searchQuery)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if searchResults.isEmpty {
                Text("No photos found")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(searchResults) { photo in
                    VStack(alignment: .leading) {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                            .padding(5)
                        
                        Text(photo.title).font(.headline)
                        Text(photo.description).font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Search Photos")
    }
}
