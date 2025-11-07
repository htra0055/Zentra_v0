//
//  FirestoreActivityList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Foundation (Apple) – https://developer.apple.com/documentation/foundation
// - FirebaseFirestore (Google, Apache 2.0 License) – https://firebase.google.com/docs/firestore
//
// Purpose:
// Represents a collection of user activities stored in Firestore.
// Provides initializers for creating lists from Firestore documents and converting to a dictionary for saving.
//

import Foundation
import FirebaseFirestore

/// `FirestoreActivityList` models a list of activity items associated with a user.
/// Conforms to `Codable` for serialization and Firestore integration.
struct FirestoreActivityList: Codable {
    /// Unique identifier for the list
    let id: String
    /// Name of the activity list
    var name: String
    /// UID of the owner (creator) of the list
    var ownerUID: String
    /// UID of the user who shared this list, if applicable
    var sharedFromUID: String?
    /// Timestamp of when the list was created or last updated
    var timestamp: Date
    /// Array of activity items included in the list
    var activities: [FirestoreActivityItem]

    // MARK: - Designated Init
    /// Initializes a new activity list
    init(id: String, name: String, ownerUID: String, sharedFromUID: String? = nil, timestamp: Date, activities: [FirestoreActivityItem]) {
        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = sharedFromUID
        self.timestamp = timestamp
        self.activities = activities
    }

    // MARK: - Init from Firestore Document
    /// Attempts to initialize an activity list from Firestore document data
    init?(from data: [String: Any], id: String) {
        guard let name = data["name"] as? String,
              let ownerUID = data["ownerUID"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let activitiesData = data["activities"] as? [[String: Any]] else {
            return nil
        }

        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = data["sharedFromUID"] as? String
        self.timestamp = timestamp.dateValue()
        self.activities = activitiesData.compactMap { FirestoreActivityItem(from: $0) }
    }

    // MARK: - Convert to Dictionary for Firestore
    /// Converts the activity list into a `[String: Any]` dictionary for Firestore
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "ownerUID": ownerUID,
            "sharedFromUID": sharedFromUID as Any,
            "timestamp": Timestamp(date: timestamp),
            "activities": activities.map { $0.toDict() }
        ]
    }
}
