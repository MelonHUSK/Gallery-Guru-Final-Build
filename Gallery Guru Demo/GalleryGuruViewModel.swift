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
    
    func getGalleryFolder() -> Folder? {
        return folders.first(where: { $0.name == "Gallery"})
    }
    
    func getPhotos(for tag: Tag) -> [Photo] {
            return photos.filter { $0.tags.contains(where: { $0.id == tag.id }) }
        }
    
    func addFolder(name: String) {
        let newFolder = Folder(name: name, photos: [])
        folders.append(newFolder)
    }
    
    func addPhoto(_ image: UIImage, tags: [Tag] = [], to folder: Folder? = nil, location: CLLocation? = nil, date: Date? = nil) {
        print("Adding photo with image: \(image)")
        
        let imageName = ""
        
        // Debug: check if the folder is valid
        print("Folder: \(folder?.name ?? "No folder provided")")
        
        let newPhoto = Photo(image: image, tags: tags, imageName: imageName, location: location, date: date)
        
        if let folderIndex = folders.firstIndex(where: { $0.id == (folder?.id ?? folders.first(where: { $0.name == "Gallery"})!.id) }) {
            print("Adding photo to folder: \(folders[folderIndex].name)")
            folders[folderIndex].photos.append(newPhoto)
        } else {
            print("Folder not found, adding photo to general gallery")
        }

        photos.append(newPhoto)
    }

    
    func removePhoto(_ photo: Photo, from folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id}) {
            folders[folderIndex].photos.removeAll { $0.id == photo.id}
        }
    }
    
    func deleteFolders(with ids: Set<UUID>) {
        folders.removeAll { folder in
            ids.contains(folder.id)
        }
    }
    
    func searchPhotos(query: String) -> [Photo] {
            let lowercasedQuery = query.lowercased()
            
            return folders.flatMap { $0.photos }.filter { photo in
                photo.title.lowercased().contains(lowercasedQuery) ||
                photo.description.lowercased().contains(lowercasedQuery)
            }
        }
    
    func addTag(_ tag: Tag) {
            // Check if the tag already exists, if not, add it to the list
            if !tags.contains(where: { $0.id == tag.id }) {
                tags.append(tag)
            }
    }
    
    func addNewTag(name: String) {
        let newTag = Tag(name: name)
        tags.append(newTag)
    }
    
    func removeTag(_ tag: Tag, from photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id}) {
            photos[index].tags.removeAll { $0.id == tag.id}
        }
    }
    
    func getAllTags() -> [Tag] {
            return tags
        }
    
    func assignTag(_ tag: Tag, to photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id}) {
            photos[index].tags.append(tag)
        }
    }
    
    func searchPhotosByDate(_ date: Date) -> [Photo] {
        return photos.filter { photo in
            guard let photoDate = photo.date else { return false }
            return Calendar.current.isDate(photoDate, inSameDayAs: date)
        }
    }
        
    func searchPhotosByLocation(_ coordinate: CLLocationCoordinate2D, radius: Double = 500) -> [Photo] {
        return photos.filter { photo in
            guard let location = photo.location else { return false }
            let photoLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let searchLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return photoLocation.distance(from: searchLocation) <= radius
        }
    }
    
    func lockFolder(_ folder: Folder, with passcode: String) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].isLocked = true
            folders[index].passcode = passcode
        }
    }
    
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
