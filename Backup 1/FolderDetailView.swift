import SwiftUI
import PhotosUI
import CoreLocation

struct FolderDetailView: View {
    @ObservedObject var folder: Folder
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var isPickerPresented = false
    @State private var showPasscodeAlert = false
    @State private var enteredPasscode = ""
    @State private var showWrongPasscodeAlert = false
    @State private var editMode = EditMode.inactive
    @State private var selectedPhotos = Set<UUID>()

    var body: some View {
        VStack {
            if folder.isLocked {
                lockedView
            } else {
                unlockedView
            }
        }
        .navigationTitle(folder.name)
        .navigationBarItems(trailing: addPhotoButton)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                deleteButton
            }
            ToolbarItem(placement: .navigationBarLeading) {
                lockButton // Lock button next to the delete button
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton() // Place EditButton here to ensure it shows
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(viewModel: viewModel, folder: folder)
        }
        .environment(\.editMode, $editMode)
    }

    private var lockedView: some View {
        VStack {
            Text("This folder is locked.")
            Button("Unlock") {
                showPasscodeAlert = true
            }
            .alert("Enter Passcode", isPresented: $showPasscodeAlert, actions: {
                TextField("Passcode", text: $enteredPasscode)
                Button("Cancel", role: .cancel) { }
                Button("Unlock") {
                    unlockFolder()
                }
            }, message: {
                Text("Enter the passcode to unlock this folder.")
            })
            .alert("Wrong Passcode", isPresented: $showWrongPasscodeAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("Incorrect passcode, please try again.")
            })
        }
    }

    private var unlockedView: some View {
        List {
            ForEach(folder.photos) { photo in
                HStack {
                    NavigationLink(destination: PhotoDetailView(photo: Binding(
                        get: { photo },
                        set: { newPhoto in
                            // Handle any changes to the photo here if necessary
                        }), viewModel: viewModel)) {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                            .padding(5)
                    }
                    if editMode.isEditing {
                        Button(action: {
                            // Handle photo selection without opening PhotoDetailView
                            if selectedPhotos.contains(photo.id) {
                                selectedPhotos.remove(photo.id)
                            } else {
                                selectedPhotos.insert(photo.id)
                            }
                        }) {
                            Image(systemName: selectedPhotos.contains(photo.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue) // Optional: Change color for visibility
                        }
                    }
                }
            }
        }
    }

    private var addPhotoButton: some View {
        Button(action: {
            isPickerPresented = true
        }) {
            Image(systemName: "plus")
        }
    }

    private var deleteButton: some View {
        Button(action: {
            if !selectedPhotos.isEmpty {
                deleteSelectedPhotos()
            }
        }) {
            Image(systemName: "trash")
        }
        .disabled(selectedPhotos.isEmpty)
    }
    
    private var lockButton: some View {
        Button(action: {
            showLockFolderAlert()
        }) {
            Image(systemName: "lock")
        }
    }

    func deleteSelectedPhotos() {
        if let folderIndex = viewModel.folders.firstIndex(where: { $0.id == folder.id }) {
            viewModel.folders[folderIndex].photos.removeAll { photo in
                selectedPhotos.contains(photo.id)
            }
            selectedPhotos.removeAll()
        }
    }

    // Function to handle unlocking the folder
    func unlockFolder() {
        if viewModel.unlockFolder(folder, passcode: enteredPasscode) {
            // Unlock folder if passcode is correct
            print("Folder unlocked")
        } else {
            // Show an error if passcode is wrong
            showWrongPasscodeAlert = true
        }
    }

    // Function to lock folder with passcode
    func showLockFolderAlert() {
        let alertController = UIAlertController(title: "Lock Folder", message: "Enter a passcode to lock this folder", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Passcode"
            textField.isSecureTextEntry = true
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Lock", style: .default, handler: { _ in
            if let passcode = alertController.textFields?.first?.text, !passcode.isEmpty {
                viewModel.lockFolder(folder, with: passcode)
            }
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @ObservedObject var viewModel: GalleryGuruViewModel
    var folder: Folder
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // No limit
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                // Debug: Print message before calling addPhoto
                                print("Calling addPhoto with image: \(uiImage)")
                                
                                // Call the addPhoto function
                                self.parent.viewModel.addPhoto(uiImage, to: self.parent.folder)
                            }
                        } else {
                            print("Error: Couldn't cast loaded object to UIImage")
                        }
                    }
                } else {
                    print("Error: itemProvider cannot load UIImage")
                }
            }
        }
    }
}
