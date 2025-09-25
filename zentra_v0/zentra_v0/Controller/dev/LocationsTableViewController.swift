////
////  LocationsTableViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 18/9/2025.
////
//
//import UIKit
//import MapKit
//
//class LocationsTableViewController: UITableViewController {
//    
//    // MARK: - Properties
//    let CELL_LOCATION = "locationCell"
//    weak var mapViewController: MapViewController?
//    var locationList = [LocationAnnotation]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Locations"
//    }
//    
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//       
//        // Force the Split View to show the detail (map)
//        splitViewController?.show(.secondary)
//    }
//
//    
//    // MARK: - Table view data source
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return locationList.count
//    }
//
//    override func tableView(_ tableView: UITableView,
//                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
//        let annotation = locationList[indexPath.row]
//        
//        // Title
//        cell.textLabel?.text = annotation.title ?? "Untitled"
//        
//        // Detail: latitude and longitude
//        let lat = annotation.coordinate.latitude
//        let lon = annotation.coordinate.longitude
//        cell.detailTextLabel?.text = String(format: "Lat: %.4f, Lon: %.4f", lat, lon)
//        
//        return cell
//    }
//    
//    // MARK: - Editing support
//    
//    override func tableView(_ tableView: UITableView,
//                            canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView,
//                            commit editingStyle: UITableViewCell.EditingStyle,
//                            forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // 1. Remove from map
//            mapViewController?.mapView.removeAnnotation(locationList[indexPath.row])
//            
//            // 2. Remove from list
//            locationList.remove(at: indexPath.row)
//            
//            // 3. Remove from table
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//    
//    // MARK: - Selecting rows
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let annotation = locationList[indexPath.row]
//        
//        // Tell the MapViewController to focus on this annotation
//        mapViewController?.focusOn(annotation: annotation)
//        
//        // Show the detail view in compact/vertical layouts
//        splitViewController?.show(.secondary)
//    }
//    
//    
//}
