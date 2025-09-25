//
//////
//////  MapViewController.swift
//////  zentra_v0
//////
//////  Created by Evelyn Tran on 18/9/2025.
//////
////
////
//
//
//
//import UIKit
//import MapKit
//
//class MapViewController: UIViewController, UISearchBarDelegate {
//
//    @IBOutlet weak var mapView: MKMapView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // MARK: - Setup Search Controller
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search for places"
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        definesPresentationContext = true // Ensure search bar doesn’t persist across navigation
//        
//        // MARK: - Set Default Map Region
//        let defaultCoordinate = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
//        let defaultRegion = MKCoordinateRegion(center: defaultCoordinate,
//                                               latitudinalMeters: 5000,
//                                               longitudinalMeters: 5000)
//        mapView.setRegion(defaultRegion, animated: false)
//    }
//    
//    // MARK: - Focus on a specific annotation
//    func focusOn(annotation: MKAnnotation) {
//        mapView.selectAnnotation(annotation, animated: true)
//        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate,
//                                            latitudinalMeters: 1000,
//                                            longitudinalMeters: 1000)
//        mapView.setRegion(zoomRegion, animated: true)
//    }
//    
//    // MARK: - UISearchBarDelegate
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        
//        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
//        
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = searchText
//        
//        let search = MKLocalSearch(request: request)
//        search.start { [weak self] response, error in
//            guard let self = self else { return }
//            guard let response = response else { return }
//            
//            // Remove previous annotations
//            self.mapView.removeAnnotations(self.mapView.annotations)
//            
//            // Add new annotations
//            for item in response.mapItems {
//                let annotation = MKPointAnnotation()
//                annotation.title = item.name
//                annotation.coordinate = item.placemark.coordinate
//                self.mapView.addAnnotation(annotation)
//            }
//            
//            // Focus on first result
//            if let firstItem = response.mapItems.first {
//                let region = MKCoordinateRegion(center: firstItem.placemark.coordinate,
//                                                latitudinalMeters: 1000,
//                                                longitudinalMeters: 1000)
//                self.mapView.setRegion(region, animated: true)
//            }
//        }
//    }
//    
//    func searchLocation(query: String) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = query
//
//        let search = MKLocalSearch(request: request)
//        search.start { response, error in
//            guard let response = response else { return }
//
//            // Clear previous annotations
//            self.mapView.removeAnnotations(self.mapView.annotations)
//
//            // Add annotations
//            for item in response.mapItems {
//                let annotation = MKPointAnnotation()
//                annotation.title = item.name
//                annotation.coordinate = item.placemark.coordinate
//                self.mapView.addAnnotation(annotation)
//            }
//
//            // Focus on first result
//            if let firstItem = response.mapItems.first {
//                let region = MKCoordinateRegion(center: firstItem.placemark.coordinate,
//                                                latitudinalMeters: 1000,
//                                                longitudinalMeters: 1000)
//                self.mapView.setRegion(region, animated: true)
//            }
//        }
//    }
//
//}
//
//
