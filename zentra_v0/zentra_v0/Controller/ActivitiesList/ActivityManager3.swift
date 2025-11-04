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

// MARK: - Saved Activity
struct SavedActivity: Identifiable, Codable {
    let id: UUID
    let name: String
    let placeID: String
    let address: String

    init(name: String, placeID: String, address: String) {
        self.id = UUID()
        self.name = name
        self.placeID = placeID
        self.address = address
    }
}

// MARK: - Activity List
struct ActivityList: Identifiable, Codable {
    let id: UUID
    var name: String
    var activities: [SavedActivity]

    init(name: String, activities: [SavedActivity] = []) {
        self.id = UUID()
        self.name = name
        self.activities = activities
    }
}

// MARK: - Activity Manager
class ActivityManager {
    static let shared = ActivityManager()
    private init() {}

    private var userLists: [ActivityList] = []

    // MARK: - Public API
    func getUserLists() -> [ActivityList] {
        return userLists
    }

    // Create a new list and save to Firebase
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

    // Add activity to list
    func addActivity(place: GMSPlace, toList list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }

        let activity = SavedActivity(
            name: place.name ?? "Unknown Place",
            placeID: place.placeID ?? "",
            address: place.formattedAddress ?? ""
        )
        userLists[index].activities.append(activity)

        // Save updated list to Firebase
        let firestoreList = convertToFirestore(userLists[index])
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
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
        return ActivityList(name: firestoreList.name, activities: activities)
    }



}

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
    
    // MARK: - Fetch Lists from Firebase - Fetch the current user's activity lists from Firestore
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
    
    func deleteList(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()

            db.collection("users").document(currentUID)
                .collection("activityLists").document(list.id.uuidString) // make sure id matches Firestore
                .delete { error in
                    completion?(error)
                }
        }
    

    
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

    

}

