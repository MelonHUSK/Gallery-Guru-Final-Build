import SwiftUI

struct FolderListView: View {
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var editMode = EditMode.inactive
    @State private var selectedFolders = Set<UUID>()
    @State private var isShowingAddFolderAlert = false
    @State private var newFolderName = ""
    @State private var isShowingPasscodeAlert = false
    @State private var folderToUnlock: Folder?
    @State private var enteredPasscode = ""

    var body: some View {
        NavigationView {
            List(selection: $selectedFolders) {
                ForEach(viewModel.folders) { folder in
                    if folder.isLocked {
                        // Show lock icon if folder is locked
                        NavigationLink(destination: LockedFolderView(folder: folder)) {
                            HStack {
                                Text(folder.name)
                                Spacer()
                                Image(systemName: "lock.fill")
                            }
                        }
                    } else {
                        // Normal folder access
                        NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                            HStack {
                                Text(folder.name)
                                Spacer()
                                if editMode.isEditing {
                                    Image(systemName: selectedFolders.contains(folder.id) ? "checkmark.circle.fill" : "circle")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                .onDelete(perform: deleteFolders)
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isShowingAddFolderAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
            .alert("New Folder", isPresented: $isShowingAddFolderAlert) {
                TextField("Folder Name", text: $newFolderName)
                Button("Cancel", role: .cancel) { }
                Button("Add", action: addFolder)
            } message: {
                Text("Enter a name for the new folder")
            }
            .alert("Enter Passcode", isPresented: $isShowingPasscodeAlert) {
                TextField("Passcode", text: $enteredPasscode)
                Button("Cancel", role: .cancel) { }
                Button("Unlock") {
                    // Validate passcode
                    if let folder = folderToUnlock, viewModel.unlockFolder(folder, passcode: enteredPasscode) {
                        // Folder unlocked
                        folderToUnlock = nil
                        enteredPasscode = ""
                    } else {
                        // Incorrect passcode
                    }
                }
            }
        }
    }
    
    private func deleteSelectedFolders() {
        viewModel.deleteFolders(with: selectedFolders)
        selectedFolders.removeAll()
    }
    
    func addFolder(){
        guard !newFolderName.isEmpty else {return}
        viewModel.addFolder(name: newFolderName)
        newFolderName = ""
    }
    
    private func deleteFolders(at offsets: IndexSet){
        offsets.map {viewModel.folders[$0].id }.forEach {id in
            selectedFolders.insert(id)
        }
        viewModel.deleteFolders(with: selectedFolders)
        selectedFolders.removeAll()
    }
}

struct LockedFolderView: View {
    var folder: Folder
    
    var body: some View {
        VStack {
            Text("This folder is locked.")
            Button("Unlock") {
                // Logic to unlock the folder (trigger passcode prompt)
            }
        }
    }
}
