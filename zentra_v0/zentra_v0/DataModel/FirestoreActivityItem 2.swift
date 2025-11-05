//
//  FirestoreActivityItem.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces


struct FirestoreActivityItem: Codable {
    let name: String
    let placeID: String
    let address: String
    let type: String?

    // MARK: - Designated Initializer
    init(name: String, placeID: String, address: String, type: String? = nil) {
        self.name = name
        self.placeID = placeID
        self.address = address
        self.type = type
    }

    // MARK: - Failable Init from Firestore Data
    init?(from data: [String: Any]) {
        guard let name = data["name"] as? String,
              let placeID = data["placeID"] as? String,
              let address = data["address"] as? String else {
            return nil
        }
        self.name = name
        self.placeID = placeID
        self.address = address
        self.type = data["type"] as? String
    }

    // MARK: - Convert to Dictionary
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "placeID": placeID,
            "address": address,
            "type": type as Any
        ]
    }
}

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

    init(id: UUID = UUID(), name: String, activities: [SavedActivity] = []) {
        self.id = id
        self.name = name
        self.activities = activities
    }
}
