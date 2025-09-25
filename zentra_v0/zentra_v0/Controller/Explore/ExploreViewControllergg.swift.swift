////
////  ExploreViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 25/9/2025.
////
//
//import UIKit
//import GoogleMaps
//import GooglePlaces
//import CoreLocation
//
//
//class ExploreViewController: UIViewController, SearchResultsUpdaterDelegate {
//
//    // MARK: - IBOutlets
//    @IBOutlet weak var mapView: GMSMapView!
//    
//    // MARK: - Properties
//    private let locationManager = CLLocationManager()
//    private var placesClient: GMSPlacesClient!
//    private var searchController: UISearchController!
//    
//    // Bottom sheet
//    private var bottomSheet: UIView!
//    private var resultsTable: UITableView!
//    private var bottomSheetHeightConstraint: NSLayoutConstraint!
//    
//    private var placeResults: [GMSPlace] = []
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Explore"
//        view.backgroundColor = .white
//        
//        // Init Google Places
//        placesClient = GMSPlacesClient.shared()
//        
//        setupMap()
//        setupSearch()
//        setupBottomSheet()
//        requestLocation()
//        
//        definesPresentationContext = true
//    }
//    
//    // MARK: - SearchResultsUpdaterDelegate
//    func performSearch(query: String) {
//        let coord = mapView.camera.target
//        searchNearby(at: coord, keyword: query)
//    }
//
//    // MARK: - Setup UI
//    private func setupMap() {
//        let camera = GMSCameraPosition.camera(
//            withLatitude: -37.8136,
//            longitude: 144.9631,
//            zoom: 14
//        )
//        mapView.camera = camera
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//    }
//
//    
//    private func setupSearch() {
//        let resultsUpdater = SearchResultsUpdater()
//        resultsUpdater.delegate = self
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = resultsUpdater
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search for places"
//        navigationItem.searchController = searchController
//    }
//    
//    private func setupBottomSheet() {
//        bottomSheet = UIView()
//        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
//        bottomSheet.backgroundColor = .systemBackground
//        bottomSheet.layer.cornerRadius = 16
//        bottomSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        bottomSheet.layer.shadowColor = UIColor.black.cgColor
//        bottomSheet.layer.shadowOpacity = 0.2
//        bottomSheet.layer.shadowRadius = 4
//        view.addSubview(bottomSheet)
//        
//        resultsTable = UITableView(frame: .zero, style: .plain)
//        resultsTable.translatesAutoresizingMaskIntoConstraints = false
//        resultsTable.dataSource = self
//        resultsTable.delegate = self
//        bottomSheet.addSubview(resultsTable)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            resultsTable.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 8),
//            resultsTable.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor),
//            resultsTable.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor),
//            resultsTable.bottomAnchor.constraint(equalTo: bottomSheet.bottomAnchor)
//        ])
//        
//        // Height constraint — collapsed by default
//        bottomSheetHeightConstraint = bottomSheet.heightAnchor.constraint(equalToConstant: 80)
//        bottomSheetHeightConstraint.isActive = true
//    }
//
//    // MARK: - Location
//    private func requestLocation() {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//    
//    // MARK: - Nearby Search
//    private func searchNearby(at coordinate: CLLocationCoordinate2D, keyword: String?) {
//        let circularLocationRestriction = GMSPlaceCircularLocationOption(coordinate, 1000) // 1km radius
//        let placeProperties = [
//            GMSPlaceProperty.name,
//            GMSPlaceProperty.coordinate,
//            GMSPlaceProperty.placeID,
//            GMSPlaceProperty.formattedAddress
//        ].map { $0.rawValue }
//        
//        var request = GMSPlaceSearchNearbyRequest(
//            locationRestriction: circularLocationRestriction,
//            placeProperties: placeProperties
//        )
//        
//        if let keyword = keyword, !keyword.isEmpty {
//            request.includedTypes = [keyword] // only works for valid place types
//        }
//        
//        GMSPlacesClient.shared().searchNearby(with: request) { [weak self] results, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Nearby search error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let results = results as? [GMSPlace] {
//                self.placeResults = results
//                self.resultsTable.reloadData()
//                self.expandBottomSheet()
//            }
//        }
//    }
//
//    // MARK: - Place Details Popup
//    private func showPlaceDetails(_ place: GMSPlace) {
//        let alert = UIAlertController(
//            title: place.name,
//            message: place.formattedAddress ?? "No address available",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    // MARK: - Bottom Sheet Helpers
//    private func expandBottomSheet() {
//        let newHeight: CGFloat = min(CGFloat(placeResults.count) * 60 + 80, 400)
//        UIView.animate(withDuration: 0.3) {
//            self.bottomSheetHeightConstraint.constant = newHeight
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    private func collapseBottomSheet() {
//        UIView.animate(withDuration: 0.3) {
//            self.bottomSheetHeightConstraint.constant = 80
//            self.view.layoutIfNeeded()
//        }
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension ExploreViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
//        locationManager.stopUpdatingLocation()
//        
//        // Initial nearby search
//        searchNearby(at: location.coordinate, keyword: "restaurant")
//    }
//}
//
//// MARK: - UITableViewDataSource & Delegate
//extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return placeResults.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        let place = placeResults[indexPath.row]
//        cell.textLabel?.text = place.name
//        cell.detailTextLabel?.text = place.formattedAddress
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let place = placeResults[indexPath.row]
//        mapView.clear()
//        let marker = GMSMarker(position: place.coordinate)
//        marker.title = place.name
//        marker.map = mapView
//        mapView.animate(toLocation: place.coordinate)
//        showPlaceDetails(place)
//    }
//}
