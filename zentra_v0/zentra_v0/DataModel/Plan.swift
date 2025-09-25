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
    
    init(activities: [Activity], mood: Mood, duration: TripDuration) {
        self.id = UUID()
        self.activities = activities
        self.mood = mood
        self.duration = duration
        self.createdAt = Date()
    }
}

enum TripDuration: String, Codable {
    case weekend = "Weekend"
    case week = "Week"
    case extended = "Extended"
}
