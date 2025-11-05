//
//  ActivityManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces
import UIKit



// MARK: - Activity Manager
class ActivityManager {
    static let shared = ActivityManager()
    private init() {}

    private var userLists: [ActivityList] = []

    // MARK: - Public API
    func getUserLists() -> [ActivityList] {
        return userLists
    }

    // MARK: - Create a New List
    func createList(name: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newList = ActivityList(name: name)
        userLists.append(newList) // keep local reference

        let firestoreList = convertToFirestore(newList)
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }

    // MARK: - Add Activity
    func addActivity(place: GMSPlace, toList list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Find the list in local cache
        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }
        
        let activity = SavedActivity(
            name: place.name ?? "Unknown Place",
            placeID: place.placeID ?? "",
            address: place.formattedAddress ?? ""
        )
        
        // Update local list
        userLists[index].activities.append(activity)
        
        // Update Firestore
        let firestoreList = convertToFirestore(userLists[index])
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }
    
    
    

    // MARK: - Delete List
    func deleteList(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Remove from local cache
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists.remove(at: index)
        }
        
        // Remove from Firestore
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(list.id.uuidString)
            .delete { error in
                completion?(error)
            }
    }
    

    // MARK: - Firestore Conversion
    func convertToFirestore(_ list: ActivityList) -> FirestoreActivityList {
        let currentUID = Auth.auth().currentUser?.uid ?? list.id.uuidString
        let firestoreActivities = list.activities.map {
            FirestoreActivityItem(name: $0.name, placeID: $0.placeID, address: $0.address, type: nil)
        }
        return FirestoreActivityList(
            id: list.id.uuidString,
            name: list.name,
            ownerUID: currentUID,
            sharedFromUID: nil,
            timestamp: Date(),
            activities: firestoreActivities
        )
    }

    func convertToLocal(_ firestoreList: FirestoreActivityList) -> ActivityList {
        let activities = firestoreList.activities.map {
            SavedActivity(name: $0.name, placeID: $0.placeID, address: $0.address)
        }
        // Preserve Firestore document ID as UUID
        return ActivityList(
            id: UUID(uuidString: firestoreList.id) ?? UUID(),
            name: firestoreList.name,
            activities: activities
        )
    }
}

// MARK: - Firestore Extension Methods
extension ActivityManager {

    /// Update a list in Firestore
    func updateListInFirestore(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        let firestoreList = convertToFirestore(list)
        db.collection("users").document(currentUID)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }
    
    // MARK: - Fetch Lists for Current User
    func fetchUserLists(completion: @escaping ([ActivityList]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else { completion([]); return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUID)
            .collection("activityLists")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                // Convert FirestoreActivityList -> ActivityList
                let lists = docs.compactMap { doc -> ActivityList? in
                    guard let firestoreList = FirestoreActivityList(from: doc.data(), id: doc.documentID) else { return nil }
                    return self.convertToLocal(firestoreList)
                }
                completion(lists)
            }
    }
    
    func saveList(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let firestoreList = convertToFirestore(list)

        db.collection("users").document(currentUID)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }

    // MARK: - Reset and Refetch
    func resetListsForNewUser() {
        userLists.removeAll()
    }

    func fetchUserListsForCurrentUser(completion: @escaping ([ActivityList]) -> Void) {
        resetListsForNewUser() // clear previous local lists first
        fetchUserLists { lists in
            self.userLists = lists
            completion(lists)
        }
    }

    
    // Mark: watch for incoming shared list
    func listenForSharedLists(onReceive: @escaping (FirestoreSharedList) -> Void) {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           let db = Firestore.firestore()

           db.collection("sharedActivities")
               .document(uid)
               .collection("sharedLists")
               .addSnapshotListener { snapshot, error in
                   guard let docs = snapshot?.documentChanges else { return }

                   for change in docs where change.type == .added {
                       if let sharedList = FirestoreSharedList(from: change.document.data(), id: change.document.documentID) {
                           onReceive(sharedList)
                       }
                   }
               }
       }


    

    
}
