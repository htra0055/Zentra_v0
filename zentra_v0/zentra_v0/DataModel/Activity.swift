//
//  Activity.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//


import Foundation
import CoreLocation




enum ActivityType: String, Codable {
    case adventure = "Adventure"
    case cultural = "Cultural"
    case foodie = "Foodie"
    case nightlife = "Nightlife"
    case relaxation = "Relaxation"
    case nature = "Nature"
}

struct Activity: Codable, Identifiable {
    let id: UUID
    let type: ActivityType
    let description: String
    
    init(type: ActivityType, description: String = "") {
        self.id = UUID()
        self.type = type
        self.description = description
    }
}

// maybe later with API
//struct Activity {
//    let name: String
//    let location: String
//    let latitude: Double
//    let longitude: Double
//    let category: String
//    let rating: Double?
//    let photoURL: String?
//
//    //    var coordinate: CLLocationCoordinate2D {
//    //        CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    //    }
//}
