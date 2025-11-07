//
//  Plan.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Foundation (Apple) – https://developer.apple.com/documentation/foundation
// - CoreLocation (Apple) – https://developer.apple.com/documentation/corelocation
//
// Purpose:
// Represents a user's planned trip, including selected activities, mood, duration, creation timestamp,
// and optional geographic location for location-based searches.
//

import Foundation
import CoreLocation

/// `Plan` models a user's trip plan with activities, energy, duration, and optional location.
struct Plan: Identifiable {
    /// Unique identifier for the plan
    let id: UUID
    /// User-selected activities
    let activities: [Activity]
    /// User-selected energy/mood
    let mood: Mood
    /// Duration of the trip
    let duration: TripDuration
    /// Timestamp when the plan was created
    let createdAt: Date
    /// Optional user location (latitude & longitude)
    let userCoordinate: CLLocationCoordinate2D?
    
    /// Designated initializer
    /// - Parameters:
    ///   - activities: List of activities chosen by the user
    ///   - mood: User-selected energy/mood
    ///   - duration: Trip duration
    ///   - userCoordinate: Optional user coordinate for location-based searches
    init(activities: [Activity],
         mood: Mood,
         duration: TripDuration,
         userCoordinate: CLLocationCoordinate2D? = nil) {
        
        self.id = UUID()
        self.activities = activities
        self.mood = mood
        self.duration = duration
        self.createdAt = Date()
        self.userCoordinate = userCoordinate
    }
}

/// `TripDuration` represents the possible lengths of a trip.
enum TripDuration: String, Codable {
    /// Short trip over the weekend
    case weekend = "Weekend"
    /// One-week trip
    case week = "Week"
    /// Extended trip longer than a week
    case extended = "Extended"
}
