//
//  Activity.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//


import Foundation
import CoreLocation

struct Activity {
    let name: String
    let location: String
    let latitude: Double
    let longitude: Double
    let category: String
}


// version with more content, maybe develop later
//struct Activity {
//    let id: UUID
//    let title: String
//    let description: String?
//    let lat: Double
//    let lon: Double
//    let category: String?
//    let rating: Double?
//    let photoURL: String?
//
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    }
//}


