//
//  SavedandSharedItem.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//
//  Purpose:
//  Defines models for saved activities and activity lists, including optional sharing metadata.
//
//  Dependencies:
//  - Foundation
//  - FirebaseFirestore
//  - FirebaseAuth
//  - GooglePlaces
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces

// MARK: - Saved Activity

/// Represents a single saved activity selected by a user.
struct SavedActivity: Identifiable, Codable {
    
    /// Unique identifier for the activity.
    let id: UUID
    
    /// Name of the activity/place.
    let name: String
    
    /// Place ID (from Google Places or internal database).
    let placeID: String
    
    /// Address of the activity/place.
    let address: String
    
    /// Initializes a new `SavedActivity`.
    /// - Parameters:
    ///   - name: Name of the activity.
    ///   - placeID: Place identifier.
    ///   - address: Address of the activity.
    init(name: String, placeID: String, address: String) {
        self.id = UUID()
        self.name = name
        self.placeID = placeID
        self.address = address
    }
}

// MARK: - Activity List

/// Represents a list of saved activities, optionally shared by another user.
struct ActivityList: Identifiable, Codable {
    
    /// Unique identifier for the activity list.
    let id: UUID
    
    /// Name of the activity list.
    var name: String
    
    /// Array of activities in the list.
    var activities: [SavedActivity]
    
    /// Optional name of the user who shared this list.
    var sharedFromName: String?
    
    /// Initializes a new `ActivityList`.
    /// - Parameters:
    ///   - id: Unique identifier (defaults to a new UUID if not provided).
    ///   - name: Name of the list.
    ///   - activities: Activities contained in the list (default empty array).
    ///   - sharedFromName: Optional name of the user who shared this list.
    init(id: UUID = UUID(), name: String, activities: [SavedActivity] = [], sharedFromName: String? = nil) {
        self.id = id
        self.name = name
        self.activities = activities
        self.sharedFromName = sharedFromName
    }
}
