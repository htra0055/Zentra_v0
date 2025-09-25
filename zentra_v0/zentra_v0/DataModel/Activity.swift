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
        case .Adventure: return "hiking trails"
        case .Cultural: return "museums"
        case .Foodie: return "restaurants"
        case .Nightlife: return "bars"
        case .Relaxation: return "spas"
        case .Nature: return "parks"
        }
    }
}


