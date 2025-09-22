//
//  FilteredPhotosView.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 16.08.2024.
//

import SwiftUI

struct FilteredPhotosView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    var selectedTag: Tag
    
    var body: some View {
        List {
            ForEach(viewModel.photos.filter { $0.tags.contains(selectedTag) }) {photo in
                Text(photo.imageName)
            }
        }
        .navigationTitle("Photos tagged: \(selectedTag.name)")
    }
}

