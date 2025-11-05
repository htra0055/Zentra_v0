////
////   MyListTableViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 24/9/2025.
////
//
//
//import UIKit
//import GooglePlaces
//import CoreLocation
//import FirebaseAuth
//import FirebaseFirestore
//
//class MyListTableViewController: UITableViewController {
//
//    // MARK: - Properties
//    private let CELL_LIST = "listCell"
//    private var userLists: [ActivityList] = []
//    private var isShowingSharedListAlert = false
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Activities"
//        configureUI()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadListsFromFirestore()
//        observeIncomingSharedLists()
//    }
//
//    // MARK: - UI Configuration
//    private func configureUI() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_LIST)
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewList)),
//            UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonTapped(_:)))
//        ]
//    }
//
//    // MARK: - Load Lists
//    private func loadListsFromFirestore() {
//        ActivityManager.shared.fetchUserLists { [weak self] lists in
//            guard let self = self else { return }
//            self.userLists = lists
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//
//    // MARK: - TableView DataSource
//    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return userLists.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)
//        let list = userLists[indexPath.row]
//        cell.textLabel?.text = list.name
//        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
//
//    // MARK: - Swipe to Delete
//    override func tableView(
//        _ tableView: UITableView,
//        commit editingStyle: UITableViewCell.EditingStyle,
//        forRowAt indexPath: IndexPath
//    ) {
//        if editingStyle == .delete {
//            let listToDelete = userLists[indexPath.row]
//            userLists.remove(at: indexPath.row)
//            ActivityManager.shared.deleteList(listToDelete) { error in
//                if let error = error {
//                    print("Error deleting list: \(error)")
//                }
//            }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
//
//    // MARK: - TableView Delegate
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let list = userLists[indexPath.row]
//        performSegue(withIdentifier: "showMyActivities", sender: list)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showMyActivities",
//           let activityVC = segue.destination as? MyActivityTableViewController,
//           let selectedList = sender as? ActivityList {
//            activityVC.activityList = selectedList
//        }
//    }
//
//    // MARK: - Share Button Actions
//    @objc private func shareButtonTapped(_ sender: Any) {
//        let listSelectionAlert = UIAlertController(
//            title: "Select List to Share",
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//
//        for list in userLists {
//            listSelectionAlert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
//                self.showShareOptions(for: list)
//            }))
//        }
//
//        listSelectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(listSelectionAlert, animated: true)
//    }
//
//    private func showShareOptions(for list: ActivityList) {
//        let shareAlert = UIAlertController(
//            title: "Share '\(list.name)' via",
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//
//        shareAlert.addAction(UIAlertAction(title: "Friend List", style: .default, handler: { _ in
//            self.shareViaFriendList(list)
//        }))
//
//        shareAlert.addAction(UIAlertAction(title: "AirDrop / Apps", style: .default, handler: { _ in
//            self.shareViaAirDrop(list)
//        }))
//
//        shareAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(shareAlert, animated: true)
//    }
//
//    private func shareViaFriendList(_ list: ActivityList) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let friendListVC = storyboard.instantiateViewController(withIdentifier: "FriendListTableViewController") as? FriendListTableViewController {
//            friendListVC.activitiesToShare = list.activities.map {
//                MockPlace(name: $0.name, address: $0.address)
//            }
//            navigationController?.pushViewController(friendListVC, animated: true)
//        }
//    }
//
//    private func shareViaAirDrop(_ list: ActivityList) {
//        let activityText = list.activities.map { "\($0.name) - \($0.address)" }.joined(separator: "\n")
//        let shareText = "Check out my activity list \"\(list.name)\":\n\n\(activityText)"
//        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
//
//        if let popover = activityVC.popoverPresentationController {
//            popover.barButtonItem = navigationItem.rightBarButtonItem
//        }
//
//        present(activityVC, animated: true)
//    }
//
//    // MARK: - Observe Shared Lists
//    private func observeIncomingSharedLists() {
//        ActivityManager.shared.listenForSharedLists { [weak self] sharedList in
//            guard let self = self, !self.isShowingSharedListAlert else { return }
//            self.isShowingSharedListAlert = true
//
//            DispatchQueue.main.async {
//                let alert = UIAlertController(
//                    title: "New Shared List",
//                    message: "\(sharedList.fromName) shared '\(sharedList.listName)' with you.",
//                    preferredStyle: .alert
//                )
//
//                alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
//                    self.rejectSharedList(sharedList)
//                    self.isShowingSharedListAlert = false
//                }))
//
//                alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
//                    self.acceptSharedList(sharedList)
//                    self.isShowingSharedListAlert = false
//                }))
//
//                self.present(alert, animated: true)
//            }
//        }
//    }
//
//    private func removeSharedList(_ sharedList: FirestoreSharedList) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore()
//            .collection("sharedActivities")
//            .document(uid)
//            .collection("sharedLists")
//            .document(sharedList.id)
//            .delete()
//    }
//    
//    // MARK: - Create New List
//    @objc private func addNewList() {
//        let alert = UIAlertController(
//            title: "New Activity List",
//            message: "Enter a name for your list:",
//            preferredStyle: .alert
//        )
//
//        alert.addTextField { textField in
//            textField.placeholder = "e.g. Weekend Adventures"
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
//            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces),
//                  !name.isEmpty else { return }
//
//            ActivityManager.shared.createList(name: name) { error, _ in
//                if let error = error {
//                    print("Error creating list: \(error)")
//                }
//                self.loadListsFromFirestore()
//            }
//        }))
//
//        present(alert, animated: true)
//    }
//
//    // MARK: - Accept/Reject Shared Lists
//    private func acceptSharedList(_ sharedList: FirestoreSharedList) {
//        ActivityManager.shared.acceptSharedList(sharedList) { error in
//            if let error = error {
//                print("Error accepting shared list: \(error)")
//            } else {
//                print("Shared list accepted.")
//                self.loadListsFromFirestore()
//            }
//        }
//    }
//
//    private func rejectSharedList(_ sharedList: FirestoreSharedList) {
//        ActivityManager.shared.removeSharedList(sharedList)
//    }
//
//}
//
//// MARK: - Mock Helper Struct
//struct MockPlace {
//    let name: String
//    let address: String
//}
