//
//  ContentView.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 13.08.2024.
//

import SwiftUI
import PhotosUI

struct StartScreenView: View {
    @StateObject var viewModel = GalleryGuruViewModel() //Refer to the view model
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                //Button to open the built-in IOS photo picker
                NavigationLink(destination: PhotosPickerView(viewModel: viewModel)) {
                    Text("Add Photos")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(Color.white)
                        .cornerRadius(10)
                }

                //Button to view all photos in the gallery
                NavigationLink(destination: GalleryView(viewModel: viewModel)) {
                    Text("View Gallery")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(Color.white)
                        .cornerRadius(10)
                }
                
                //Button to view all folders
                NavigationLink(destination: FolderListView(viewModel: viewModel)) {
                    Text("Folders")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(Color.white)
                        .cornerRadius(10)
                }

                // New button to select a tag
                NavigationLink(destination: TagSelectionView(viewModel: viewModel)) {
                    Text("Select Tag")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(Color.white)
                        .cornerRadius(10)
                }
                
                //Button to search photos by desc or title
                NavigationLink(destination: PhotoSearchView(viewModel: viewModel)) {
                    Text("Search Photos")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(Color.white)
                        .cornerRadius(10)
                }
                
                //Button to search photos by date
                NavigationLink(destination: SearchByDateView(viewModel: viewModel)) {
                    Text("Search by Date")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
                //Button to search photos by coordinates
                NavigationLink(destination: SearchByLocationView(viewModel: viewModel)) {
                    Text("Search by Location")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
            }
            .padding()
            .navigationTitle("Gallery Guru")
        }
    }
}

#Preview {
    ContentView()
}
