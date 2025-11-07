//
//  ExploreViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 25/9/2025.
//
// Acknowledgements:
//
// Libraries:
// - Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore
// - Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth
// - Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//
//External Resources / Tutorials:
//- StackOverflow – various Swift Firestore examples (https://stackoverflow.com/questions/70864512/get-all-collections-that-are-declared-on-document-swift-firestore-firebase)
//- YouTube tutorial on GMSPlace integration (https://www.youtube.com/watch?v=Jj7f5W2W1h0)


import UIKit
import MapKit
import CoreLocation

class ExploreViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!

    private let locationManager = CLLocationManager()

  
    private var bottomSheet: UIView!
    private var resultsTable: UITableView!
    private var bottomSheetHeightConstraint: NSLayoutConstraint!

    private var placeResults: [MKMapItem] = []

    // MARK: - Lifecycle
    /// Sets up map view, search bar, bottom sheet, and location manager on view load.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"

        mapView.delegate = self
        mapView.showsUserLocation = false
        setupSearch()
        setupBottomSheet()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    // MARK: - Search
    /// Configures UISearchController and integrates it into the navigation bar.
    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for places"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // Triggered when search button is tapped. Performs local search for entered query.
    /// - Parameter searchBar: The UISearchBar that initiated the search.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(query: searchBar.text ?? "")
    }
    
    /// Performs a local search using MKLocalSearch with the given query and updates results.
    /// - Parameter query: The search query string.
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
            self.updateMapAnnotations()
        }
    }

    /// Updates map annotations to reflect current search results.
    private func updateMapAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        for item in placeResults {
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - Bottom Sheet
    /// Sets up the bottom sheet UI and results table for displaying search results.
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

    /// Expands the bottom sheet based on the number of search results.
    private func expandBottomSheet() {
        let newHeight: CGFloat = min(CGFloat(placeResults.count) * 60 + 80, 400)
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }

    /// Collapses the bottom sheet to default height.
    private func collapseBottomSheet() {
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeightConstraint.constant = 80
            self.view.layoutIfNeeded()
        }
    }

    /// Performs a nearby search around a given coordinate using a keyword.
    /// - Parameters:
    ///   - coordinate: The center coordinate for the search.
    ///   - keyword: The keyword to search for (e.g., "restaurant").
    private func performNearbySearch(at coordinate: CLLocationCoordinate2D, keyword: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self, let response = response else { return }
            self.placeResults = response.mapItems
            self.resultsTable.reloadData()
            self.expandBottomSheet()
            self.updateMapAnnotations()
        }
    }


    // MARK: - Save Activity Helpers
    /// Saves a selected place to an existing activity list and updates Firestore.
    /// - Parameters:
    ///   - item: The MKMapItem to save.
    ///   - list: The ActivityList to save the item into.
    private func saveItem(_ item: MKMapItem, to list: ActivityList) {
        let activity = SavedActivity(
            name: item.name ?? "Unknown Place",
            placeID: item.placemark.name ?? UUID().uuidString,
            address: item.placemark.title ?? ""
        )

        var updatedList = list
        updatedList.activities.append(activity)

        ActivityManager.shared.updateListInFirestore(updatedList) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error saving activity: \(error)")
            } else {
                DispatchQueue.main.async {
                    let confirmation = UIAlertController(
                        title: "Saved!",
                        message: "\(item.name ?? "Place") has been saved to \"\(list.name)\".",
                        preferredStyle: .alert
                    )
                    confirmation.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(confirmation, animated: true)
                }
            }
        }
    }

    /// Creates a new activity list, adds the selected place to it, and updates Firestore.
    /// - Parameter item: The MKMapItem to save in the new list.
    private func createNewListWithActivity(_ item: MKMapItem) {
        let alert = UIAlertController(title: "New List", message: "Enter a name for your new list", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "List Name" }

        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let listName = alert.textFields?.first?.text, !listName.isEmpty else { return }

   
            ActivityManager.shared.createList(name: listName) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Error creating new list: \(error)")
                    return
                }

       
                ActivityManager.shared.fetchUserLists { lists in
                    guard let newList = lists.first(where: { $0.name == listName }) else { return }

          
                    let activity = SavedActivity(
                        name: item.name ?? "Unknown Place",
                        placeID: item.placemark.name ?? UUID().uuidString,
                        address: item.placemark.title ?? ""
                    )
                    var updatedList = newList
                    updatedList.activities.append(activity)

          
                    ActivityManager.shared.updateListInFirestore(updatedList) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error saving activity: \(error)")
                            } else {
                                let confirmation = UIAlertController(
                                    title: "Saved!",
                                    message: "\(item.name ?? "Place") has been saved to \"\(listName)\".",
                                    preferredStyle: .alert
                                )
                                confirmation.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(confirmation, animated: true)
                            }
                        }
                    }
                }
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    /// Displays a list selection alert and allows user to save a place to an existing list or create a new one.
    /// - Parameter item: The MKMapItem to save.
    private func savePlaceToList(_ item: MKMapItem) {
        
        ActivityManager.shared.fetchUserLists { lists in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Select a list", message: nil, preferredStyle: .alert)

                if lists.isEmpty {
                  
                    alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
                        self.createNewListWithActivity(item)
                    }))
                } else {
                  
                    for list in lists {
                        alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
                            self.saveItem(item, to: list)
                        }))
                    }
                   
                    alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
                        self.createNewListWithActivity(item)
                    }))
                }

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension ExploreViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    /// Handles changes in location authorization and updates map settings accordingly.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }

    /// Receives location updates, centers the map on the user, adds annotation, and performs nearby search.
    /// - Parameter locations: Array of CLLocation objects.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "You are here"
        mapView.addAnnotation(annotation)
        performNearbySearch(at: location.coordinate, keyword: "restaurant")
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource & Delegate
    /// Returns number of search result rows in the results table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeResults.count
    }

    /// Configures a table view cell to display a search result with name and address.
    /// - Parameters:
    ///   - tableView: The UITableView displaying results.
    ///   - indexPath: The index path of the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = placeResults[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.placemark.title
        return cell
    }

    /// Handles selection of a search result, providing options to view details, get directions, or save to list.
    /// - Parameters:
    ///   - tableView: The UITableView displaying results.
    ///   - indexPath: The index path of the selected cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = placeResults[indexPath.row]
        mapView.setCenter(item.placemark.coordinate, animated: true)

        let alert = UIAlertController(title: item.name, message: item.placemark.title, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "View Details", style: .default, handler: { _ in
            self.showPlaceDetails(item)
        }))
        alert.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
            let directionsVC = DirectionsViewController()
            directionsVC.destination = item
            self.navigationController?.pushViewController(directionsVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Save to My List", style: .default, handler: { _ in
            self.savePlaceToList(item)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView.cellForRow(at: indexPath)
            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
        }

        present(alert, animated: true)
    }

    /// Displays detailed information about a selected place and allows opening in Safari or canceling.
    /// - Parameter item: The MKMapItem to show details for.
    private func showPlaceDetails(_ item: MKMapItem) {
        
        let message = """
        Address: \(item.placemark.title ?? "Unknown")
        Phone: \(item.phoneNumber ?? "N/A")
        """

        let detailsAlert = UIAlertController(title: item.name, message: message, preferredStyle: .alert)
        detailsAlert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
            
            if let name = item.name,
               let address = item.placemark.title {
                let query = "\(name) \(address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let query = query, let url = URL(string: "https://www.google.com/search?q=\(query)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))

        
        detailsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(detailsAlert, animated: true)
    }


}

// MARK: - MKMapViewDelegate
/// Placeholder for MKMapViewDelegate methods for map customization.
extension ExploreViewController: MKMapViewDelegate {}
