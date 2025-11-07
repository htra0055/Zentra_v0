//
//  Activity.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.

// Acknowledgements:
//
// Libraries & SDKs:
// - Foundation (Apple) – https://developer.apple.com/documentation/foundation
// - CoreLocation (Apple) – https://developer.apple.com/documentation/corelocation
//
// Purpose:
// Defines the `Activity` enum representing user-selectable activity types for trip planning.
// Provides a `query` property for mapping activities to search keywords used in external APIs or search engines.
//

import Foundation
import CoreLocation


/// `Activity` represents different types of user interests for trips or plans.
/// Conforms to `String` and `Codable` for storage and serialization.
enum Activity: String, Codable {
    case Adventure = "Adventure"
    case Cultural = "Cultural"
    case Foodie = "Foodie"
    case Nightlife = "Nightlife"
    case Relaxation = "Relaxation"
    case Nature = "Nature"
}

extension Activity {
    /// Returns a query string that can be used for search or API requests corresponding to the activity type.
    var query: String {
        switch self {
        case .Adventure: return "Adventure" // "hiking trails, camping"
        case .Cultural: return "Cultural" // "museums, art galleries, historic sites"
        case .Foodie: return "Foodie" // "restaurants, cafes, street food"
        case .Nightlife: return "Nightlife" // "bars, live music venues" //, clubs, live music venues"
        case .Relaxation: return "Relaxation" // "spas, yoga studios" //, wellness centers
        case .Nature: return "Nature"  //"parks, beaches, forests, nature reserves"
        }
    }
}


