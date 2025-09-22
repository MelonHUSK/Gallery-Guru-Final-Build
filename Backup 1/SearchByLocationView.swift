import SwiftUI
import MapKit

struct SearchByLocationView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var searchResults: [Photo] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region)
                .frame(height: 300)
            
            Button("Search Photos by Location") {
                searchResults = viewModel.searchPhotosByLocation(region.center)
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
                                if let location = photo.location {
                                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search by Location")
    }
}
