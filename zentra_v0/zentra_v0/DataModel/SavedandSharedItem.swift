//
//  SavedandSharedItem.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces

// MARK: - Saved Activity
struct SavedActivity: Identifiable, Codable {
    let id: UUID
    let name: String
    let placeID: String
    let address: String

    init(name: String, placeID: String, address: String) {
        self.id = UUID()
        self.name = name
        self.placeID = placeID
        self.address = address
    }
}

// MARK: - Activity List
struct ActivityList: Identifiable, Codable {
    let id: UUID
    var name: String
    var activities: [SavedActivity]
    var sharedFromName: String? 

    init(id: UUID = UUID(), name: String, activities: [SavedActivity] = [], sharedFromName: String? = nil) {
        self.id = id
        self.name = name
        self.activities = activities
        self.sharedFromName = sharedFromName
    }
}
