//
//  FirestoreActivityItem.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Foundation (Apple) – https://developer.apple.com/documentation/foundation
// - FirebaseFirestore (Google, Apache 2.0 License) – https://firebase.google.com/docs/firestore
// - FirebaseAuth (Google, Apache 2.0 License) – https://firebase.google.com/docs/auth
// - Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//
// Purpose:
// Represents an individual activity item stored in Firestore.
// Provides initializers for creating items from Firestore documents and converting to a dictionary for saving.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces

/// `FirestoreActivityItem` models an activity selected by the user, storing essential info for Firestore.
/// Conforms to `Codable` for serialization.
struct FirestoreActivityItem: Codable {
    let name: String
    let placeID: String
    let address: String
    let type: String?

    // MARK: - Designated Initializer
    /// Creates a new activity item
    init(name: String, placeID: String, address: String, type: String? = nil) {
        self.name = name
        self.placeID = placeID
        self.address = address
        self.type = type
    }

    // MARK: - Failable Init from Firestore Data
    /// Attempts to initialize from Firestore document data
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
    /// Converts the activity item into a `[String: Any]` dictionary for Firestore saving
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "placeID": placeID,
            "address": address,
            "type": type as Any
        ]
    }
}

