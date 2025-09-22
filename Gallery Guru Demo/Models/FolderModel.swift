//
//  FolderModel.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 14.08.2024.
//

import SwiftUI
import Foundation
import CoreLocation

//Tag model
struct Tag: Identifiable, Hashable {
    let id: UUID                //Unique ID
    var name: String            //Type should be string
    
    init(name: String) {
        self.id = UUID()        //UUID is initialised by self
        self.name = name        //Name is set by the user
    }
}

//Folder model
class Folder: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String             //Folder name
    @Published var photos: [Photo]          //Photos inside folder
    @Published var isLocked: Bool           //Determines if a folder is locker
    @Published var passcode: String?        //Password of the folder (empty by default)
    
    //Attributes init by self
    init(name: String, photos: [Photo] = [], isLocked: Bool = false, passcode: String? = nil) {
        self.id = UUID()
        self.name = name
        self.photos = photos
        self.isLocked = isLocked
        self.passcode = passcode
    }
}

//Photo model
class Photo: Identifiable, ObservableObject {
    let id: UUID
    @Published var image: UIImage               //The actual image stored inside the class
    @Published var imageName: String            //Name of image (imported)
    @Published var tags: [Tag]                  //Tags assigned to image
    @Published var title: String                //Title of image (assigned by user)
    @Published var description: String          //Desc of image
    @Published var location: CLLocation?        //The location of the image (may be empty in case there is no metadata)
    @Published var date: Date?                  //Date of image (may be empty in case there is no metadata)
    
    //Attributes init by self
    init(image: UIImage, tags: [Tag] = [], imageName: String, title: String = "", description: String = "", location: CLLocation? = nil, date: Date? = nil) {
        self.id = UUID()
        self.imageName = imageName
        self.image = image
        self.tags = tags
        self.title = title
        self.description = description
        self.location = location
        self.date = date
    }
}
