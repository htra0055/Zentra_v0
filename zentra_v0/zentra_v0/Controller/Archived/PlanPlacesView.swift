//// PlanPlacesView.swift
//
//
//
//import SwiftUI
//import GooglePlacesSwift
//import CoreLocation
//
//struct PlanPlacesView: View {
//    let plan: Plan
//    
//    // State array of PlaceDetailsQuery for each activity
//    @State private var queries: [PlaceDetailsQuery] = []
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                ForEach(queries.indices, id: \.self) { index in
//                    let query = queries[index]
//                    
//                    // Use the compact vertical PlaceDetails view
//                    PlaceDetailsCompactView(
//                        orientation: .vertical,
//                        query: $queries[index],
//                        configuration: configuration,
//                        placeDetailsCallback: { result in
//                            if let place = result.place {
//                                print("Fetched place: \(place.description)")
//                            } else if let error = result.error {
//                                print("Error fetching place: \(error)")
//                            }
//                        }
//                    )
//                    .frame(width: UIScreen.main.bounds.width - 32)
//                    .padding(.horizontal, 16)
//                }
//            }
//            .padding(.vertical, 16)
//        }
//        .onAppear {
//            buildQueries()
//        }
//    }
//    
//    // Configuration for all PlaceDetails views
//    var configuration: PlaceDetailsConfiguration {
//        var theme = PlacesMaterialTheme()
//        // Customize theme if needed
//        return PlaceDetailsConfiguration(content: Set(PlaceDetailsContent.standardContent), theme: theme)
//    }
//    
//    // Build a PlaceDetailsQuery for each activity in the plan
//    private func buildQueries() {
//        queries = plan.activities.map { activity in
//            // Use the activity query text
//            PlaceDetailsQuery(identifier: .textSearch(activity.query))
//        }
//    }
//}
//
