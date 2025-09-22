//Main file used for previews
//Do NOT edit

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GalleryGuruViewModel() //The view model being used
    
    var body: some View {
        StartScreenView(viewModel: viewModel) //Reference the scene loaded at startup
    }
}

#Preview {
    ContentView()
}
