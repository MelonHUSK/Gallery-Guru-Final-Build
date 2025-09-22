//
//  FolderViewModel.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 14.08.2024.
//

import SwiftUI
import CoreLocation

class GalleryGuruViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var photos: [Photo] = []
    @Published var tags: [Tag] = []
    @Published var imageName: String = ""
    
    init() {
        if !folders.contains(where: { $0.name == "Gallery"}) {
            let galleryFolder = Folder(name: "Gallery")
            folders.append(galleryFolder)
        }
    }
     
    // Get all photos from gallery
    func getGalleryFolder() -> Folder? {
        return folders.first(where: { $0.name == "Gallery"})
    }
    
        // Reference all tags
    func getAllTags() -> [Tag] {
            return tags
        }

        // Get photos by tag
    func getPhotosByTag(for tag: Tag) -> [Photo] {
        return folders.flatMap { $0.photos }.filter { $0.tags.contains(where: { $0.id == tag.id }) }
    }

        // Create new folder
    func addFolder(name: String) {
        let newFolder = Folder(name: name, photos: [])
        folders.append(newFolder)
    }
    
    // Add photo to a specific folder
    func addPhoto(_ image: UIImage, tags: [Tag] = [], to folder: Folder? = nil, location: CLLocation? = nil, date: Date? = nil) {
        print("Adding photo with image: \(image)")

        let imageName = UUID().uuidString
        let newPhoto = Photo(image: image, tags: tags, imageName: imageName, location: location, date: date)

        // Handle the hash and duplicates check here
        guard let newImageHash = differenceHash(for: image) else {
            print("Error: Could not generate hash for the new image.")
            return
        }
        
        // Check for duplicates before adding
        if let existingPhoto = findPhoto(withHash: newImageHash) {
            print("Duplicate photo detected. Moving to the 'Duplicates' folder.")
            movePhotoToDuplicateFolder(newPhoto)
        } else {
            // No duplicate found, proceed to add the photo
            if let folderIndex = folders.firstIndex(where: { $0.id == (folder?.id ?? folders.first(where: { $0.name == "Gallery"})!.id) }) {
                print("Adding photo to folder: \(folders[folderIndex].name)")
                folders[folderIndex].photos.append(newPhoto) // Append the new photo here
                addPhotoToServer(image: image)
                objectWillChange.send() // Notify that the object has changed
            } else {
                print("Folder not found, adding photo to general gallery")
            }
        }
    }

    // Calculate the hash of an imported photo
    private func findPhoto(withHash newHash: UInt64) -> Photo? {
            let threshold = 1
            
            // Unroll all photos in all folders to compare
            for folder in folders {
                for photo in folder.photos {
                    if let photoHash = differenceHash(for: photo.image) {
                        let distance = hammingDistance(photoHash, newHash)
                        //If hashe are too similar, the photos are duplicates
                        if distance < threshold {
                            return photo
                        }
                    }
                }
            }
            return nil
        }

        // Move the photo to the "Duplicate" folder
        private func movePhotoToDuplicateFolder(_ photo: Photo) {
            let duplicateFolder = folders.first { $0.name == "Duplicates" } ?? createDuplicateFolder()

            if let folderIndex = folders.firstIndex(where: { $0.id == duplicateFolder.id }) {
                folders[folderIndex].photos.append(photo)
                print("Duplicate photo moved to 'Duplicates' folder.")
            }
        }

        // Create a "Duplicates" folder if it doesn't exist
        private func createDuplicateFolder() -> Folder {
            let duplicateFolder = Folder(name: "Duplicates", photos: [])
            folders.append(duplicateFolder)
            print("'Duplicates' folder created.")
            return duplicateFolder
        }

    // Export photo to server
    func addPhotoToServer(image: UIImage) {
        guard let url = URL(string: "http://localhost/GalleryGuru/saveUploads.php") else {
            print("Invalid server URL")
            return
        }

        // Convert image to Base64 string
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }

        let base64String = imageData.base64EncodedString()

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Prepare the body
        let body = "image=\(base64String)"
        request.httpBody = body.data(using: .utf8)

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading photo: \(error)")
                return
            }
            
            // Check response status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Photo uploaded successfully")
            } else {
                print("Failed to upload photo, response: \(response!)")
            }
        }
        
        task.resume()
    }

    // Delete a photo from a folder
    func removePhoto(_ photo: Photo, from folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id}) {
            folders[folderIndex].photos.removeAll { $0.id == photo.id}
        }
    }
    
    // Delete a folder
    func deleteFolders(with ids: Set<UUID>) {
        folders.removeAll { folder in
            ids.contains(folder.id)
        }
    }
    
    // Search photos by desc
    func searchPhotosByDesc(query: String) -> [Photo] {
            let lowercasedQuery = query.lowercased()
            
            return folders.flatMap { $0.photos }.filter { photo in
                photo.title.lowercased().contains(lowercasedQuery) ||
                photo.description.lowercased().contains(lowercasedQuery)
            }
        }
    
    // Create a new tag
    func addTag(_ tag: Tag) {
            // Check if the tag already exists, if not, add it to the list
            if !tags.contains(where: { $0.id == tag.id }) {
                tags.append(tag)
            }
    }
    
    //Remove a tag from a photo
    func removeTag(_ tag: Tag, from photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id}) {
            photos[index].tags.removeAll { $0.id == tag.id}
        }
    }
    
    // Add a tag to a photo
    func assignTag(_ tag: Tag, to photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index].tags.append(tag)
        }
    }
    
    // Search a photo by a date
    func searchPhotosByDate(_ date: Date) -> [Photo] {
        return folders.flatMap { $0.photos }.filter { photo in
            guard let photoDate = photo.date else { return false }
            return Calendar.current.isDate(photoDate, inSameDayAs: date)
        }
    }
        
    // Search a photo by a location
    func searchPhotosByLocation(_ coordinate: CLLocationCoordinate2D, radius: Double = 50000) -> [Photo] {
        return folders.flatMap { $0.photos }.filter { photo in
            guard let location = photo.location else { return false }
            let photoLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let searchLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return photoLocation.distance(from: searchLocation) <= radius
        }
    }
    
    // Lock a folder behind a password
    func lockFolder(_ folder: Folder, with passcode: String) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].isLocked = true
            folders[index].passcode = passcode
        }
    }
    
    //Unlock a locked folder
    func unlockFolder(_ folder: Folder, passcode: String) -> Bool {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            if folders[index].passcode == passcode {
                folders[index].isLocked = false
                folders[index].passcode = nil
                return true
            }
        }
        return false
    }
}

