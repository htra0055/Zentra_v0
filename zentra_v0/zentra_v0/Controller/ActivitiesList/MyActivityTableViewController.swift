//
//  MyActibityTableViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 24/9/2025.
//


import UIKit
import GooglePlaces
import GooglePlacesSwift
import SwiftUI
import CoreLocation


class MyActivityTableViewController: UITableViewController {

    let CELL_ACTIVITY = "activityCell"
    var activityList: ActivityList? // passed from MyListTableViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = activityList?.name ?? "My Activities"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ACTIVITY)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList?.activities.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ACTIVITY, for: indexPath)
        if let activity = activityList?.activities[indexPath.row] {
            cell.textLabel?.text = activity.name
            cell.detailTextLabel?.text = activity.address
        }
        return cell
        
    }
    

    func deleteActivity(_ activity: SavedActivity) {
        guard var list = activityList else { return }
        list.activities.removeAll { $0.id == activity.id }
        ActivityManager.shared.updateList(list)
        activityList = list
    }

    // MARK: - Enable Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let activity = activityList?.activities[indexPath.row] else { return }
            
            // Delete activity
            deleteActivity(activity)
            
            // Update table
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }


    // MARK: - Share Button
    @IBAction func shareButtonTapped(_ sender: Any) {
        
//        guard let list = activityList else { return }
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let friendListVC = storyboard.instantiateViewController(withIdentifier: "FriendListTableViewController") as? FriendListTableViewController {
//            // Convert activities to share
//            friendListVC.activitiesToShare = list.activities.map {
//                MockPlace(name: $0.name, address: $0.address)
//            }
//            navigationController?.pushViewController(friendListVC, animated: true)
//        }
    }
}
