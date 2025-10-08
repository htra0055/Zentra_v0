//
//  Plan.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//



import Foundation
import CoreLocation


struct Plan: Identifiable {
    let id: UUID
    let activities: [Activity]
    let mood: Mood
    let duration: TripDuration
    let createdAt: Date
    let userCoordinate: CLLocationCoordinate2D?
    
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

enum TripDuration: String, Codable {
    case weekend = "Weekend"
    case week = "Week"
    case extended = "Extended"
}
