//
//  FindPlaceEngine.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 22/9/2025.
//

import Foundation
import CoreLocation
import GooglePlaces

class FindPlaceEngine {

    static let shared = FindPlaceEngine()
    private init() {}

    // MARK: - Main function to find places based on user's plan
    func findPlaces(for plan: Plan,
                    location: CLLocationCoordinate2D,
                    maxResults: Int = 10,
                    completion: @escaping (Result<[GMSPlace], Error>) -> Void) {
        
        
        // 1. Build query using Activity.query for better search results
        var queryParts: [String] = plan.activities.map { $0.query }
        queryParts.append(plan.mood.rawValue)
        queryParts.append(plan.duration.rawValue)
        let query = queryParts.joined(separator: " ")


        // 2. Place properties to fetch
        let properties: [GMSPlaceProperty] = [
            .name, .placeID, .coordinate, .types, .rating,
            .businessStatus, .openingHours
        ]

        // 3. Create request
        let request = GMSPlaceSearchByTextRequest(
            textQuery: query,
            placeProperties: properties.map { $0.rawValue }
        )
        request.isOpenNow = true
        request.maxResultCount = Int32(maxResults)
        request.rankPreference = .distance
        request.locationBias = GMSPlaceCircularLocationOption(location, 5000) // 5km
        request.isStrictTypeFiltering = false


        // 4. Perform search
        GMSPlacesClient.shared().searchByText(with: request) { results, error in
            if let error = error {
                print(" Places API error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let places = results as? [GMSPlace] else {
                completion(.success([]))
                return
            }

            // 5. Optionally sort or filter results before returning
            let sortedPlaces = places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }

            completion(.success(sortedPlaces))
        }
    }

    // MARK: - Helper: check if a place is open
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
