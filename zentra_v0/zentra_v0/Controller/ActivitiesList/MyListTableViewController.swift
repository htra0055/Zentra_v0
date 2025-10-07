//
//   MyListTableViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 24/9/2025.
//


import UIKit
import GooglePlaces
import GooglePlacesSwift
import SwiftUI
import CoreLocation


import UIKit

class MyListTableViewController: UITableViewController {

    let CELL_LIST = "listCell"
    var userLists: [ActivityList] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Activity Lists"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_LIST)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewList)),
            UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonTapped(_:)))
        ]

        loadUserLists()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserLists()
    }

    private func loadUserLists() {
        userLists = ActivityManager.shared.getUserLists()
        tableView.reloadData()
    }

    // MARK: - Create New List
    @objc private func addNewList() {
        let alert = UIAlertController(title: "New Activity List",
                                      message: "Enter a name for your list:",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "e.g. Weekend Adventures"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let name = alert.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            let _ = ActivityManager.shared.createList(name: name)
            self.loadUserLists()
        }))
        present(alert, animated: true)
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)
        let list = userLists[indexPath.row]
        cell.textLabel?.text = list.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Enable Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let listToDelete = userLists[indexPath.row]
            
    
            userLists.remove(at: indexPath.row)
            ActivityManager.shared.deleteList(listToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }


    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = userLists[indexPath.row]
        performSegue(withIdentifier: "showMyActivities", sender: list)
    }

    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyActivities",
           let activityVC = segue.destination as? MyActivityTableViewController,
           let selectedList = sender as? ActivityList {  // use the actual type
            activityVC.activityList = selectedList
        }
    }


    // MARK: - Share Button
    @objc func shareButtonTapped(_ sender: Any) {
        // Step 1: Choose the list
        let listSelectionAlert = UIAlertController(title: "Select List to Share", message: nil, preferredStyle: .actionSheet)
        
        for list in userLists {
            listSelectionAlert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
                // Step 2: Choose sharing method
                self.showShareOptions(for: list)
            }))
        }
        
        listSelectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(listSelectionAlert, animated: true)
    }

    // Step 2: Show sharing options
    private func showShareOptions(for list: ActivityList) {
        let shareAlert = UIAlertController(title: "Share '\(list.name)' via", message: nil, preferredStyle: .actionSheet)
        
        // Friend List
        shareAlert.addAction(UIAlertAction(title: "Friend List", style: .default, handler: { _ in
            self.shareViaFriendList(list)
        }))
        
        // AirDrop / Other Apps
        shareAlert.addAction(UIAlertAction(title: "AirDrop / Apps", style: .default, handler: { _ in
            self.shareViaAirDrop(list)
        }))
        
        shareAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(shareAlert, animated: true)
    }

    // Existing share functions
    private func shareViaFriendList(_ list: ActivityList) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let friendListVC = storyboard.instantiateViewController(withIdentifier: "FriendListTableViewController") as? FriendListTableViewController {
            friendListVC.activitiesToShare = list.activities.map { activity in
                MockPlace(name: activity.name, address: activity.address)
            }
            navigationController?.pushViewController(friendListVC, animated: true)
        }
    }

    private func shareViaAirDrop(_ list: ActivityList) {
        // Convert list to readable string
        let activityText = list.activities.map { "\($0.name) - \($0.address)" }.joined(separator: "\n")
        let shareText = "Check out my activity list \"\(list.name)\":\n\n\(activityText)"
        
        // Standard iOS share sheet
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // For iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }


}

// Helper struct for sharing mock data
struct MockPlace {
    let name: String
    let address: String
}
