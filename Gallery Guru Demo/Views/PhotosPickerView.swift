//
//  PhotosPickerView.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 14.08.2024.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotosPickerView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?
    
    struct Tag: Identifiable {
        let id = UUID() // Unique identifier for the tag
        var name: String
    }
    
    var body: some View {
        VStack {
            Button(action: {
                isPickerPresented = true
            }) {
                Text("Import Photos")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPickerPresented){
                imagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) {newImage in
                if let image = newImage {
                    viewModel.addPhoto(image, tags: [], to: viewModel.folders.first(where: {$0.name == "Gallery"}))
                }
            }
        }
        .navigationTitle("Add Photos")
    }
}

struct imagePicker: UIViewControllerRepresentable{
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: imagePicker
        
        init(_ parent: imagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


