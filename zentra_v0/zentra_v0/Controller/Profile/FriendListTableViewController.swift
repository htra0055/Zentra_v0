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


// v1
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
                                      message: "Enter email of the user to add",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "User email"; $0.keyboardType = .emailAddress }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let email = alert.textFields?.first?.text?.lowercased(), !email.isEmpty else { return }
            self.addFriend(withEmail: email)
        }))
        present(alert, animated: true)
    }

    private func addFriend(withEmail email: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error { print("Error: \(error.localizedDescription)"); return }
            guard let doc = snapshot?.documents.first, let name = doc.data()["name"] as? String else {
                self.showAlert(title: "Error", message: "User not found")
                return
            }
            let newFriend = User(id: email, name: name)
            if self.friends.contains(where: { $0.id == email }) {
                self.showAlert(title: "Info", message: "Friend already added")
                return
            }
            let currentUserRef = self.db.collection("users").document(currentUID)
            currentUserRef.updateData(["friends": FieldValue.arrayUnion([email])]) { error in
                if let error = error { print("Error updating friends: \(error.localizedDescription)"); return }
                self.friends.append(newFriend)
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }
    }

    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }


    // MARK: - TableView DataSource & Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { friends.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.name
        cell.accessoryType = selectedFriends.contains(where: { $0.id == friend.id }) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        if !selectedFriends.contains(where: { $0.id == friend.id }) { selectedFriends.append(friend) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        selectedFriends.removeAll { $0.id == friend.id }
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
        let activitiesData = activitiesToShare.map { ["placeID": $0.name, "name": $0.name, "address": $0.address] }
        db.collection("users").whereField("email", isEqualTo: friend.id).getDocuments { snapshot, error in
            guard let doc = snapshot?.documents.first else { return }
            self.db.collection("users").document(doc.documentID).collection("sharedActivities").addDocument(data: [
                "fromUserId": Auth.auth().currentUser?.uid ?? "",
                "activities": activitiesData,
                "timestamp": Timestamp()
            ])
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
            
            guard let data = snapshot?.data(), let friendEmails = data["friends"] as? [String] else {
                self.friends = []
                self.tableView.reloadData()
                return
            }
            
            let group = DispatchGroup()
            var fetchedFriends: [User] = []
            
            for email in friendEmails {
                group.enter()
                self.db.collection("users").whereField("email", isEqualTo: email).getDocuments { snap, error in
                    defer { group.leave() }
                    guard let doc = snap?.documents.first,
                          let name = doc.data()["name"] as? String else { return }
                    fetchedFriends.append(User(id: email, name: name))
                }
            }
            
            group.notify(queue: .main) {
                self.friends = fetchedFriends
                self.tableView.reloadData()
            }
        }
    }

}

