//
//  FriendListTableViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

import UIKit
import GooglePlaces
import FirebaseFirestore
import FirebaseAuth

class FriendListTableViewController: UITableViewController {

    var friends: [User] = []
    var activitiesToShare: [MockPlace] = []
    private var selectedFriends: [User] = []

    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Friends"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.allowsMultipleSelection = true

        loadFriends()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(shareButtonTapped))

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addFriendTapped))

        // Add a back/close button if presented modally
        if presentingViewController != nil && navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                              target: self,
                                              action: #selector(closeButtonTapped))
            navigationItem.leftBarButtonItem = closeButton
        }
    }

    // MARK: - Close Modal
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - Add Friend
    @objc private func addFriendTapped() {
        let alert = UIAlertController(title: "Add Friend",
                                      message: "Enter the user's email or user ID",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Email or User ID"; $0.keyboardType = .emailAddress }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let identifier = alert.textFields?.first?.text?.lowercased(), !identifier.isEmpty else { return }
            self.addFriend(withIdentifier: identifier)
        }))
        present(alert, animated: true)
    }

    private func addFriend(withIdentifier identifier: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        // Determine whether to query by email or userID
        let queryField: String = identifier.contains("@") ? "email" : "userID"

        db.collection("users").whereField(queryField, isEqualTo: identifier).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to fetch user")
                return
            }

            guard let doc = snapshot?.documents.first else {
                self.showAlert(title: "Error", message: "User not found")
                return
            }

            let data = doc.data()

            // Safely extract fields with fallback values
            let uid = data["uid"] as? String ?? doc.documentID
            let email = data["email"] as? String ?? "Unknown Email"
            let name = data["name"] as? String ?? email
            let userID = data["userID"] as? String

            let newFriend = User(uid: uid, email: email, name: name, userID: userID)

            // Check if already added
            if self.friends.contains(where: { $0.uid == newFriend.uid }) {
                self.showAlert(title: "Info", message: "Friend already added")
                return
            }

            // Update current user's friends array in Firestore
            let currentUserRef = self.db.collection("users").document(currentUID)
            currentUserRef.updateData(["friends": FieldValue.arrayUnion([newFriend.uid])]) { error in
                if let error = error {
                    print("Error updating friends: \(error.localizedDescription)")
                    return
                }

                // Append new friend and reload table on main thread
                DispatchQueue.main.async {
                    self.friends.append(newFriend)
                    self.tableView.reloadData()
                }
            }
        }
    }

    


    // MARK: - Alert helper
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }

    // MARK: - TableView DataSource & Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { friends.count }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
//        let friend = friends[indexPath.row]
//        cell.textLabel?.text = friend.name ?? friend.email
//        cell.accessoryType = selectedFriends.contains(where: { $0.uid == friend.uid }) ? .checkmark : .none
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let friend = friends[indexPath.row]

        // Ensure there is always a visible title
        if let name = friend.name, !name.isEmpty {
            cell.textLabel?.text = name
        } else if !friend.email.isEmpty {
            cell.textLabel?.text = friend.email
        } else {
            cell.textLabel?.text = "Unknown User"
        }

        cell.accessoryType = selectedFriends.contains(where: { $0.uid == friend.uid }) ? .checkmark : .none
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        if !selectedFriends.contains(where: { $0.uid == friend.uid }) {
            selectedFriends.append(friend)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        selectedFriends.removeAll { $0.uid == friend.uid }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Enable swipe-to-delete
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let friendToRemove = friends[indexPath.row]

            // Remove from Firestore current user's friends array
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            let currentUserRef = db.collection("users").document(currentUID)
            currentUserRef.updateData(["friends": FieldValue.arrayRemove([friendToRemove.uid])]) { error in
                if let error = error {
                    print("Error removing friend: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to remove friend")
                    return
                }

                // Remove locally and update table view
                DispatchQueue.main.async {
                    self.friends.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    // Optional: customize the swipe delete button title
    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }


    // MARK: - Share
    @objc private func shareButtonTapped() {
        guard !selectedFriends.isEmpty, !activitiesToShare.isEmpty else {
            showAlert(title: "Error", message: "Select friends and activities to share")
            return
        }

        for friend in selectedFriends { shareActivities(with: friend) }

        showAlert(title: "Success", message: "Activities shared!") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func shareActivities(with friend: User) {
        let activitiesData = activitiesToShare.map { ["name": $0.name, "address": $0.address] }

        db.collection("users").document(friend.uid).collection("sharedActivities").addDocument(data: [
            "fromUserId": Auth.auth().currentUser?.uid ?? "",
            "activities": activitiesData,
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error sharing activities: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Load Friends
    private func loadFriends() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(), let friendUIDs = data["friends"] as? [String] else {
                self.friends = []
                self.tableView.reloadData()
                return
            }

            let group = DispatchGroup()
            var fetchedFriends: [User] = []

            for uid in friendUIDs {
                group.enter()
                self.db.collection("users").document(uid).getDocument { doc, error in
                    defer { group.leave() }
                    if let data = doc?.data(), let user = User(from: data) {
                        fetchedFriends.append(user)
                    }
                }
            }

            group.notify(queue: .main) {
                self.friends = fetchedFriends
                self.tableView.reloadData()
            }
        }
    }
}
