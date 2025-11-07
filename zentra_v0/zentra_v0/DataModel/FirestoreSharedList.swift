//
//  FirestoreSharedList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 5/11/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Foundation (Apple) – https://developer.apple.com/documentation/foundation
// - FirebaseFirestore (Google, Apache 2.0 License) – https://firebase.google.com/docs/firestore
//
// Purpose:
// Represents activity lists shared by other users via Firestore.
// Provides initializers to parse Firestore documents and convert to local ActivityList.
//

import Foundation
import FirebaseFirestore

/// `FirestoreSharedList` models a list of activities shared by another user.
/// Includes metadata about the sender and timestamp.
struct FirestoreSharedList {
    /// Unique identifier for the shared list
    let id: String
    /// UID of the user who shared the list
    let fromUID: String
    /// Display name of the user who shared the list
    let fromName: String
    /// Name of the shared list
    let listName: String
    /// Array of shared activity items
    let activities: [SharedActivityItem]
    /// Timestamp when the list was shared
    let timestamp: Date
    
    // MARK: - Init from Firestore Document
    /// Failable initializer from Firestore document data
    /// - Parameters:
    ///   - dict: Firestore document as `[String: Any]`
    ///   - id: Document ID
    init?(from dict: [String: Any], id: String) {
        guard let fromUID = dict["fromUID"] as? String,
              let fromName = dict["fromName"] as? String,
              let listName = dict["listName"] as? String,
              let activitiesArray = dict["activities"] as? [[String: Any]],
              let timestamp = dict["timestamp"] as? Timestamp
        else { return nil }
        
        self.id = id
        self.fromUID = fromUID
        self.fromName = fromName
        self.listName = listName
        self.timestamp = timestamp.dateValue()
        self.activities = activitiesArray.compactMap { SharedActivityItem(from: $0) }
    }
    
    // MARK: - Conversion
    /// Converts shared Firestore list to local `ActivityList`
    func toActivityList() -> ActivityList {
        let savedActivities = activities.map { SavedActivity(name: $0.name, placeID: "", address: $0.address) }
        return ActivityList(name: listName, activities: savedActivities)
    }
}

/// `SharedActivityItem` models a single activity in a shared list.
struct SharedActivityItem {
    /// Name of the activity/place
    let name: String
    /// Address of the activity/place
    let address: String
    
    // MARK: - Init from Firestore Data
    /// Failable initializer from Firestore document data
    init?(from dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let address = dict["address"] as? String else { return nil }
        self.name = name
        self.address = address
    }
    
    // MARK: - Convert to Dictionary
    /// Converts activity item to `[String: Any]` for Firestore storage
    func toDict() -> [String: Any] {
        return ["name": name, "address": address]
    }
}
