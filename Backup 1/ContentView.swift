import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GalleryGuruViewModel()
    
    var body: some View {
        StartScreenView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
