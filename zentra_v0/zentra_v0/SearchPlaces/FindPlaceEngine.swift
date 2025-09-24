//
//
////  FindPlaceEngine.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 22/9/2025.
////
//
//import Foundation
//import CoreLocation
//import GooglePlaces
//
//class FindPlaceEngine {
//
//    static let shared = FindPlaceEngine()
//    private init() {}
//
//    // MARK: - Main function to find places based on user's plan
//    func findPlaces(for plan: Plan,
//                    location: CLLocationCoordinate2D,
//                    maxResults: Int = 10,
//                    completion: @escaping ([GMSPlace]) -> Void) {
//
//        // Construct a text query based on activities
//        let query = plan.activities.map { $0.type.rawValue }.joined(separator: ", ")
//
//        // Select place properties you want to fetch
//        let properties: [GMSPlaceProperty] = [
//            .name, .placeID, .coordinate, .types, .rating, .businessStatus, .openingHours
//        ]
//        let request = GMSPlaceSearchByTextRequest(textQuery: query,
//                                                  placeProperties: properties.map { $0.rawValue })
//
//        // Optional filters
//        request.isOpenNow = true
//        request.maxResultCount = maxResults
//        request.rankPreference = .distance
//        request.locationBias = GMSPlaceCircularLocationOption(location, 5000) // 5km radius
//        request.isStrictTypeFiltering = false
//
//        // Perform the search
//        GMSPlacesClient.shared().searchByText(with: request) { results, error in
//            if let error = error {
//                print("Error fetching places: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//
//            guard let places = results as? [GMSPlace] else {
//                completion([])
//                return
//            }
//
//            completion(places)
//        }
//    }
//
//    // MARK: - Optional helper to check if a place is currently open
//    func isPlaceOpen(_ place: GMSPlace, completion: @escaping (GMSPlaceOpenStatus) -> Void) {
//        let openRequest = GMSPlaceIsOpenRequest(place: place, date: nil)
//        GMSPlacesClient.shared().isOpen(with: openRequest) { response, error in
//            guard error == nil, let response = response else {
//                completion(.unknown)
//                return
//            }
//            completion(response.status)
//        }
//    }
//}
