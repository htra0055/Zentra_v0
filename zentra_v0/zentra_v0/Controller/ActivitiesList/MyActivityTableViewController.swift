//
//  MyActibityTableViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 24/9/2025.
//


//Acknowledgements:
//
//Libraries:
//- Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore
//- Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth
//- Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//


import UIKit
import GooglePlaces
import GooglePlacesSwift
import SwiftUI
import CoreLocation

/// View controller that displays a table of activities in a selected ActivityList.
/// Allows viewing, deleting, and managing individual activities.
class MyActivityTableViewController: UITableViewController {

    let CELL_ACTIVITY = "activityCell"
    var activityList: ActivityList?

    
    // MARK: - View Lifecycle
       
    /// Called after the controller's view is loaded into memory.
    /// Sets up the title and registers the table view cell class.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = activityList?.name ?? "My Activities"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ACTIVITY)
    }

    
    /// Returns the number of rows in the given section.
    /**
     - Parameters:
     - tableView: The table view requesting this information.
     - section: Section index (only 1 section is used here).
     - Returns: Number of activities in the list, or 0 if none.
     */
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList?.activities.count ?? 0
    }
    
    /// Configures and returns the cell for a given row.
    /// - Parameters:
    ///   - tableView: The table view requesting the cell.
    ///   - indexPath: Index path of the row.
    /// - Returns: Configured `UITableViewCell` displaying activity name and address.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ACTIVITY, for: indexPath)
        if let activity = activityList?.activities[indexPath.row] {
            cell.textLabel?.text = activity.name
            cell.detailTextLabel?.text = activity.address
        }
        return cell
        
    }
    
    // MARK: - Activity Management
        
    /// Deletes a specific activity from the current list.
    /// Updates both the local `activityList` and Firestore.
    /// - Parameter activity: The `SavedActivity` object to delete.
    func deleteActivity(_ activity: SavedActivity) {
        guard var list = activityList else { return }
        list.activities.removeAll { $0.id == activity.id }
        ActivityManager.shared.updateListInFirestore(list) { error in
            if let error = error {
                print("Failed to update list: \(error)")
            } else {
                print("List updated in Firestore successfully")
            }
        }
        activityList = list
    }
    
    

    // MARK: - Swipe to Delete
        
    /// Enables swipe-to-delete functionality in the table view.
    /// Deletes the activity from both local cache and Firestore.
    /**
      - Parameters:
      - tableView: The table view requesting this action.
      - editingStyle: The editing style (e.g., `.delete`).
      - indexPath: Index path of the row being edited.
    */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let activity = activityList?.activities[indexPath.row] else { return }
            deleteActivity(activity)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
