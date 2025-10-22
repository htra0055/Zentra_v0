////
////  ExploreViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 25/9/2025.
////
//import UIKit
//import MapKit
//import CoreLocation
//
//class ExploreViewController: UIViewController, UISearchBarDelegate {
//
//    @IBOutlet weak var mapView: MKMapView!
//    
////    let lists = ActivityManager.shared.getUserLists()
//    
//    private let locationManager = CLLocationManager()
//    
//    // Bottom sheet
//    private var bottomSheet: UIView!
//    private var resultsTable: UITableView!
//    private var bottomSheetHeightConstraint: NSLayoutConstraint!
//    
//    private var placeResults: [MKMapItem] = []
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Explore"
//
//        mapView.delegate = self
//        mapView.showsUserLocation = false // enable after authorization
//        setupSearch()
//        setupBottomSheet()
//
//        // Request location access
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//
//    // MARK: - Location
//    private func requestLocation() {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    // MARK: - Search
//    private func setupSearch() {
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search for places"
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        performSearch(query: searchBar.text ?? "")
//    }
//
//    func performSearch(query: String) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = query
//        request.region = mapView.region
//        
//        let search = MKLocalSearch(request: request)
//        search.start { [weak self] response, error in
//            guard let self = self, let response = response else { return }
//            self.placeResults = response.mapItems
//            self.resultsTable.reloadData()
//            self.expandBottomSheet()
//            
//            self.mapView.removeAnnotations(self.mapView.annotations)
//            for item in self.placeResults {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = item.placemark.coordinate
//                annotation.title = item.name
//                self.mapView.addAnnotation(annotation)
//            }
//        }
//    }
//
//    // MARK: - Bottom Sheet
//    private func setupBottomSheet() {
//        bottomSheet = UIView()
//        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
//        bottomSheet.backgroundColor = .systemBackground
//        bottomSheet.layer.cornerRadius = 16
//        bottomSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        view.addSubview(bottomSheet)
//        
//        resultsTable = UITableView(frame: .zero, style: .plain)
//        resultsTable.translatesAutoresizingMaskIntoConstraints = false
//        resultsTable.dataSource = self
//        resultsTable.delegate = self
//        bottomSheet.addSubview(resultsTable)
//        
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
//        bottomSheetHeightConstraint = bottomSheet.heightAnchor.constraint(equalToConstant: 80)
//        bottomSheetHeightConstraint.isActive = true
//    }
//
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
//    
//    private func performNearbySearch(at coordinate: CLLocationCoordinate2D, keyword: String) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = keyword
//        request.region = MKCoordinateRegion(center: coordinate,
//                                            latitudinalMeters: 1000,
//                                            longitudinalMeters: 1000)
//        
//        let search = MKLocalSearch(request: request)
//        search.start { [weak self] response, error in
//            guard let self = self, let response = response else { return }
//            
//            self.placeResults = response.mapItems
//            self.resultsTable.reloadData()
//            self.expandBottomSheet()
//            
//            self.mapView.removeAnnotations(self.mapView.annotations)
//            for item in self.placeResults {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = item.placemark.coordinate
//                annotation.title = item.name
//                self.mapView.addAnnotation(annotation)
//            }
//        }
//    }
//
//}
//
//// MARK: - CLLocationManagerDelegate
//extension ExploreViewController: CLLocationManagerDelegate {
//
//    
////    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        guard let location = locations.last else { return }
////
////        // Show user location on map
////        mapView.showsUserLocation = true
////        mapView.userTrackingMode = .follow
////
////        // Center the map on user location
////        let region = MKCoordinateRegion(center: location.coordinate,
////                                        latitudinalMeters: 1000,
////                                        longitudinalMeters: 1000)
////        mapView.setRegion(region, animated: true)
////        locationManager.stopUpdatingLocation()
////
////        // Optional: initial search for nearby restaurants
////        performNearbySearch(at: location.coordinate, keyword: "restaurant")
////    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            mapView.showsUserLocation = true // blue dot shows after permission
//            mapView.userTrackingMode = .follow // zooms to user automatically
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        // Stop updates to save battery
//        locationManager.stopUpdatingLocation()
//
//        // Zoom in manually (optional if using userTrackingMode)
//        let region = MKCoordinateRegion(
//            center: location.coordinate,
//            latitudinalMeters: 1000,
//            longitudinalMeters: 1000
//        )
//        mapView.setRegion(region, animated: true)
//
//        // Add optional annotation
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location.coordinate
//        annotation.title = "You are here"
//        mapView.addAnnotation(annotation)
//
//        // Optional: search nearby places
//        performNearbySearch(at: location.coordinate, keyword: "restaurant")
//    }
//
//
//
//
//}
//
//
//// MARK: - UITableViewDataSource & Delegate
//extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
//    
//
//
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return placeResults.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        let item = placeResults[indexPath.row]
//        cell.textLabel?.text = item.name
//        cell.detailTextLabel?.text = item.placemark.title
//        return cell
//    }
//    
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let item = placeResults[indexPath.row]
////        let annotation = MKPointAnnotation()
////        annotation.coordinate = item.placemark.coordinate
////        annotation.title = item.name
////        mapView.addAnnotation(annotation)
////        mapView.setCenter(item.placemark.coordinate, animated: true)
////        
////        let alert = UIAlertController(title: item.name, message: item.placemark.title, preferredStyle: .alert)
////        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
////        present(alert, animated: true)
////    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = placeResults[indexPath.row]
//        
//        // Center map on the selected place
//        mapView.setCenter(item.placemark.coordinate, animated: true)
//        
//        // Show alert with options
//        let alert = UIAlertController(title: item.name, message: item.placemark.title, preferredStyle: .actionSheet)
//        
//        // 1. View Details (open a new view controller or show alert)
//        alert.addAction(UIAlertAction(title: "View Details", style: .default, handler: { _ in
//            self.showPlaceDetails(item)
//        }))
//        
//        // 2. Get Directions
//        alert.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
//            self.openMapsForDirections(to: item)
//        }))
//        
//        // 3. Save to List
//        alert.addAction(UIAlertAction(title: "Save to My List", style: .default, handler: { _ in
//            self.savePlaceToList(item)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // For iPad
//        if let popover = alert.popoverPresentationController {
//            popover.sourceView = tableView.cellForRow(at: indexPath)
//            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
//        }
//        
//        present(alert, animated: true)
//    }
//
//    // MARK: - Helpers
//    
//    private func showPlaceDetails(_ item: MKMapItem) {
//        // Construct message with address + phone
//        let message = """
//        Address: \(item.placemark.title ?? "Unknown")
//        Phone: \(item.phoneNumber ?? "N/A")
//        """
//
//        let detailsAlert = UIAlertController(title: item.name, message: message, preferredStyle: .alert)
//        
//        // Open in Safari option
//        detailsAlert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
//            // Combine name + address for Google search
//            if let name = item.name,
//               let address = item.placemark.title {
//                let query = "\(name) \(address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//                if let query = query, let url = URL(string: "https://www.google.com/search?q=\(query)") {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }
//        }))
//        
//        // Cancel option
//        detailsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(detailsAlert, animated: true)
//    }
//
//
//
//
//    private func openMapsForDirections(to item: MKMapItem) {
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        item.openInMaps(launchOptions: launchOptions)
//    }
//
//    private func savePlaceToList(_ item: MKMapItem) {
//        let userLists = ActivityManager.shared.getUserLists()
//        
//        if userLists.isEmpty {
//            // No list, create default
//            ActivityManager.shared.saveMKMapItemToDefaultList(item)
//        } else {
//            // Ask user which list to save
//            let alert = UIAlertController(title: "Select a list", message: nil, preferredStyle: .alert)
//            
//            for list in userLists {
//                alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
//                    ActivityManager.shared.addMKMapItemToList(item, list: list)
//                }))
//            }
//            
//            // Option to create new list
//            alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
//                self.createNewListAndAddMKMapItem(item)
//            }))
//            
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            present(alert, animated: true)
//        }
//        
//        let confirmation = UIAlertController(
//            title: "Saved!",
//            message: "\(item.name ?? "Place") has been saved to your list.",
//            preferredStyle: .alert
//        )
//        confirmation.addAction(UIAlertAction(title: "OK", style: .default))
//        present(confirmation, animated: true)
//    }
//
//
//    
//    private func createNewListAndAddMKMapItem(_ item: MKMapItem) {
//        let alert = UIAlertController(title: "New List", message: "Enter a name for your new list", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "List Name"
//        }
//        
//        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
//            guard let listName = alert.textFields?.first?.text, !listName.isEmpty else { return }
//            let newList = ActivityManager.shared.createList(name: listName)
//            ActivityManager.shared.addMKMapItemToList(item, list: newList)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//
//
//
//
//
//
//
//    
//}
//
//// MARK: - MKMapViewDelegate
//extension ExploreViewController: MKMapViewDelegate {}
//
