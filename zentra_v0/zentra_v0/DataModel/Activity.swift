//
//  Activity.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//


import Foundation
import CoreLocation



enum Activity: String, Codable {
    case Adventure = "Adventure"
    case Cultural = "Cultural"
    case Foodie = "Foodie"
    case Nightlife = "Nightlife"
    case Relaxation = "Relaxation"
    case Nature = "Nature"
}

extension Activity {
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


