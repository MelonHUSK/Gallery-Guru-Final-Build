import SwiftUI

struct SearchByDateView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var selectedDate = Date()
    @State private var searchResults: [Photo] = []
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            Button("Search Photos by Date") {
                // Update the search results whenever the button is pressed
                searchResults = viewModel.searchPhotosByDate(selectedDate)
            }
            .padding()
            
            if searchResults.isEmpty {
                Text("No photos found")
                    .padding()
            } else {
                List(searchResults) { photo in
                    NavigationLink(destination: PhotoDetailView(photo: Binding(
                        get: { photo },
                        set: { newPhoto in
                            // Handle any changes to the photo here if necessary
                        }), viewModel: viewModel)) {
                        HStack {
                            Image(uiImage: photo.image)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                            
                            VStack(alignment: .leading) {
                                Text(photo.imageName)
                                if let date = photo.date {
                                    Text("Date: \(formattedDate(date))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search by Date")
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
