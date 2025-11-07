//
//  FindPlaceEngine.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 22/9/2025.
//  Main function to find places based on user's plan, take user input for location, if not, put default

import Foundation
import CoreLocation
import GooglePlaces

class FindPlaceEngine {

    static let shared = FindPlaceEngine()
    private init() {}

  
    
    // MARK: Determine search location: user input or device's current location. Fallback to a default coordinate if location not available
    
    func findPlaces(for plan: Plan,
                    userInputLocation: CLLocationCoordinate2D?, // optional input
                    maxResults: Int = 15,
                    completion: @escaping (Result<[GMSPlace], Error>) -> Void) {


        let searchLocation: CLLocationCoordinate2D
        if let userLoc = userInputLocation {
            searchLocation = userLoc
        } else if let currentLoc = CLLocationManager().location?.coordinate {
            searchLocation = currentLoc
        } else {
            searchLocation = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9663)
            

        }
        // MARK: 1. Build query
        var queryParts: [String] = plan.activities.map { $0.query }
        queryParts.append("Find me places that")
        queryParts.append(plan.mood.rawValue)
        queryParts.append(plan.duration.rawValue)
        let query = queryParts.joined(separator: " ")

        // MARK: Place properties to fetch
        let properties: [GMSPlaceProperty] = [
            .name, .placeID, .coordinate, .types, .rating,
            .businessStatus, .openingHours,  .photos
        ]

        // MARK: Create request
        let request = GMSPlaceSearchByTextRequest(
            textQuery: query,
            placeProperties: properties.map { $0.rawValue }
        )
        request.isOpenNow = true
        request.maxResultCount = Int32(maxResults)
        request.rankPreference = .distance
        request.locationBias = GMSPlaceCircularLocationOption(searchLocation, 5000) // 5km
        request.isStrictTypeFiltering = false

        // MARK: Perform search
        GMSPlacesClient.shared().searchByText(with: request) { results, error in
            if let error = error {
                print("Places API error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let places = results as? [GMSPlace] else {
                completion(.success([]))
                return
            }

            let sortedPlaces = places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            completion(.success(sortedPlaces))
        }
    }

    
  
    
    // MARK:  Helper: check if a place is open
    func isPlaceOpen(_ place: GMSPlace,
                     completion: @escaping (GMSPlaceOpenStatus) -> Void) {
        let openRequest = GMSPlaceIsOpenRequest(place: place, date: nil)
        GMSPlacesClient.shared().isOpen(with: openRequest) { response, error in
            if let error = error {
                print(" Error checking open status: \(error.localizedDescription)")
                completion(.unknown)
                return
            }
            
            completion(response.status)
        }
    }
}
