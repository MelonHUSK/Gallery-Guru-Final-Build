//
//  FolderModel.swift
//  Gallery Guru Demo
//
//  Created by Doruk AKALIN on 14.08.2024.
//

import SwiftUI
import Foundation

struct Tag: Identifiable, Hashable {
    let id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

class Folder: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var photos: [Photo]
    @Published var isLocked: Bool
    @Published var passcode: String?
    
    init(name: String, photos: [Photo] = [], isLocked: Bool = false, passcode: String? = nil) {
        self.id = UUID()
        self.name = name
        self.photos = photos
        self.isLocked = isLocked
        self.passcode = passcode
    }
}
