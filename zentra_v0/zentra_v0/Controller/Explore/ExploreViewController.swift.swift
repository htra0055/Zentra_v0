//
//  ExploreViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 25/9/2025.
//
import UIKit
import MapKit
import CoreLocation

class ExploreViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    // Bottom sheet
    private var bottomSheet: UIView!
    private var resultsTable: UITableView!
    private var bottomSheetHeightConstraint: NSLayoutConstraint!
    
    private var placeResults: [MKMapItem] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"

        mapView.delegate = self
        mapView.showsUserLocation = false // enable after authorization
        setupSearch()
        setupBottomSheet()

        // Request location access
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }


    // MARK: - Location
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Search
    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for places"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(query: searchBar.text ?? "")
    }

    func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response else { return }
            self.placeResults = response.mapItems
            self.resultsTable.reloadData()
            self.expandBottomSheet()
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            for item in self.placeResults {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    // MARK: - Bottom Sheet
    private func setupBottomSheet() {
        bottomSheet = UIView()
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        bottomSheet.backgroundColor = .systemBackground
        bottomSheet.layer.cornerRadius = 16
        bottomSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(bottomSheet)
        
        resultsTable = UITableView(frame: .zero, style: .plain)
        resultsTable.translatesAutoresizingMaskIntoConstraints = false
        resultsTable.dataSource = self
        resultsTable.delegate = self
        bottomSheet.addSubview(resultsTable)
        
        NSLayoutConstraint.activate([
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultsTable.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 8),
            resultsTable.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor),
            resultsTable.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor),
            resultsTable.bottomAnchor.constraint(equalTo: bottomSheet.bottomAnchor)
        ])
        
        bottomSheetHeightConstraint = bottomSheet.heightAnchor.constraint(equalToConstant: 80)
        bottomSheetHeightConstraint.isActive = true
    }

    private func expandBottomSheet() {
        let newHeight: CGFloat = min(CGFloat(placeResults.count) * 60 + 80, 400)
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func collapseBottomSheet() {
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeightConstraint.constant = 80
            self.view.layoutIfNeeded()
        }
    }
    
    private func performNearbySearch(at coordinate: CLLocationCoordinate2D, keyword: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response else { return }
            
            self.placeResults = response.mapItems
            self.resultsTable.reloadData()
            self.expandBottomSheet()
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            for item in self.placeResults {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension ExploreViewController: CLLocationManagerDelegate {

    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        // Show user location on map
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//
//        // Center the map on user location
//        let region = MKCoordinateRegion(center: location.coordinate,
//                                        latitudinalMeters: 1000,
//                                        longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: true)
//        locationManager.stopUpdatingLocation()
//
//        // Optional: initial search for nearby restaurants
//        performNearbySearch(at: location.coordinate, keyword: "restaurant")
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView.showsUserLocation = true // blue dot shows after permission
            mapView.userTrackingMode = .follow // zooms to user automatically
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Stop updates to save battery
        locationManager.stopUpdatingLocation()

        // Zoom in manually (optional if using userTrackingMode)
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)

        // Add optional annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "You are here"
        mapView.addAnnotation(annotation)

        // Optional: search nearby places
        performNearbySearch(at: location.coordinate, keyword: "restaurant")
    }




}


// MARK: - UITableViewDataSource & Delegate
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = placeResults[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.placemark.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = placeResults[indexPath.row]
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        mapView.addAnnotation(annotation)
        mapView.setCenter(item.placemark.coordinate, animated: true)
        
        let alert = UIAlertController(title: item.name, message: item.placemark.title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension ExploreViewController: MKMapViewDelegate {}

