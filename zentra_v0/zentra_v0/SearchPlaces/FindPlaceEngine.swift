//
//  FindPlaceEngine.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 22/9/2025.
//
//  Purpose:
//  Provides the main search engine to find places based on a user's plan, mood, and trip duration.
//  Uses Google Places SDK to perform text-based searches and sort results by rating and distance.
//
//  Features:
//  - Determines search location from user input, device location, or defaults to central Melbourne.
//  - Builds queries dynamically from plan activities, mood, and duration.
//  - Fetches detailed place properties including name, ID, types, rating, opening hours, photos, and business status.
//  - Helper method to check if a place is currently open.
//
//  Dependencies:
//  - Foundation
//  - CoreLocation
//  - GooglePlaces
//
//  Acknowledgements:
//  - Initial design ideas and logic were assisted by AI (ChatGPT) to construct a system that decodes user interests
//    and translates them into queries for Google Places API.
//  - The AI suggested building queries dynamically based on activities, mood, and trip duration to find relevant places.
//

import Foundation
import CoreLocation
import GooglePlaces

/// Engine responsible for finding places relevant to a user's plan.
class FindPlaceEngine {

    /// Shared singleton instance.
    static let shared = FindPlaceEngine()
    private init() {}
    
    // MARK: - Search Places
    
    /// Finds places matching the provided plan and optional location.
    ///
    /// - Parameters:
    ///   - plan: The user's plan containing selected activities, mood, and duration.
    ///   - userInputLocation: Optional coordinate provided by the user; if nil, uses device location or default.
    ///   - maxResults: Maximum number of places to return (default is 15).
    ///   - completion: Completion handler returning a `Result` with an array of `GMSPlace` or an `Error`.
    func findPlaces(for plan: Plan,
                    userInputLocation: CLLocationCoordinate2D?,
                    maxResults: Int = 15,
                    completion: @escaping (Result<[GMSPlace], Error>) -> Void) {
        
        // Determine the coordinate for the search
        let searchLocation: CLLocationCoordinate2D
        if let userLoc = userInputLocation {
            searchLocation = userLoc
        } else if let currentLoc = CLLocationManager().location?.coordinate {
            searchLocation = currentLoc
        } else {
            searchLocation = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9663)
        }

        // Build the search query from activities, mood, and duration
        var queryParts: [String] = plan.activities.map { $0.query }
        queryParts.append("Find me places that")
        queryParts.append(plan.mood.rawValue)
        queryParts.append(plan.duration.rawValue)
        let query = queryParts.joined(separator: " ")

        // Properties to fetch from Google Places
        let properties: [GMSPlaceProperty] = [
            .name, .placeID, .coordinate, .types, .rating,
            .businessStatus, .openingHours, .photos
        ]

        // Create the search request
        let request = GMSPlaceSearchByTextRequest(
            textQuery: query,
            placeProperties: properties.map { $0.rawValue }
        )
        request.isOpenNow = true
        request.maxResultCount = Int32(maxResults)
        request.rankPreference = .distance
        request.locationBias = GMSPlaceCircularLocationOption(searchLocation, 5000) // 5 km radius
        request.isStrictTypeFiltering = false

        // Perform the search using Google Places
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

            // Sort by rating descending
            let sortedPlaces = places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            completion(.success(sortedPlaces))
        }
    }
    
    // MARK: - Helpers
    
    /// Checks if a given place is currently open.
    ///
    /// - Parameters:
    /// - place: The `GMSPlace` to check.
    /// - completion: Completion handler returning the `GMSPlaceOpenStatus`.
    func isPlaceOpen(_ place: GMSPlace,
                     completion: @escaping (GMSPlaceOpenStatus) -> Void) {
        let openRequest = GMSPlaceIsOpenRequest(place: place, date: nil)
        GMSPlacesClient.shared().isOpen(with: openRequest) { response, error in
            if let error = error {
                print("Error checking open status: \(error.localizedDescription)")
                completion(.unknown)
                return
            }
            
            completion(response.status)
        }
    }
}
