//
//  ActivityManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

//Acknowledgements:
//
//Libraries:
//- Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore
//- Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth
//- Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//
//External Resources / Tutorials:
//- StackOverflow – various Swift Firestore examples (https://stackoverflow.com/questions/70864512/get-all-collections-that-are-declared-on-document-swift-firestore-firebase)
//- YouTube tutorial on GMSPlace integration (https://www.youtube.com/watch?v=Jj7f5W2W1h0)


import Foundation
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces
import UIKit




class ActivityManager {
    
    /// Singleton pattern to manage all user activity lists globally
    static let shared = ActivityManager()
    private init() {}

    /// userLists acts as a local cache of the user's activity lists
    /// Firestore serves as the persistent backend
    private var userLists: [ActivityList] = []

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

   
    /// Adds a new activity to a specified activity list for the current user.
    /// Updates both the local cache and Firestore.
    /// - Parameters:
    ///   - place: The `GMSPlace` object representing the activity/place to add.
    ///   - list: The `ActivityList` to which the activity should be added.
    ///   - completion: Optional closure called with an `Error` if the Firestore update fails.
    ///
    func addActivity(place: GMSPlace, toList list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }
        
        // Add activity to Firestore
        // Inspired by Firebase Firestore Swift examples: https://firebase.google.com/docs/firestore/quickstart
        let activity = SavedActivity(
            name: place.name ?? "Unknown Place",
            placeID: place.placeID ?? "",
            address: place.formattedAddress ?? ""
        )
        
     
        userLists[index].activities.append(activity)
    
        let firestoreList = convertToFirestore(userLists[index])
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }
    
    
    
    /// Deletes a specified activity list for the current user.
    /// Removes the list from the local cache and Firestore.
    /// - Parameters:
    ///   - list: The `ActivityList` object to be deleted.
    ///   - completion: Optional closure called with an `Error` if the Firestore deletion fails.
    func deleteList(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
     
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists.remove(at: index)
        }
        
        
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("activityLists").document(list.id.uuidString)
            .delete { error in
                completion?(error)
            }
    }
    

    /// Converts a local `ActivityList` into a `FirestoreActivityList` suitable for Firestore storage.
    /// - Parameters:
    ///   - list: The local `ActivityList` object to convert.
    /// - Returns: A `FirestoreActivityList` object with Firestore-compatible properties.
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

    /// Converts a `FirestoreActivityList` fetched from Firestore into a local `ActivityList`.
    /// - Parameters:
    ///   - firestoreList: The `FirestoreActivityList` object retrieved from Firestore.
    /// - Returns: A local `ActivityList` object for use in the app.
    func convertToLocal(_ firestoreList: FirestoreActivityList) -> ActivityList {
        let activities = firestoreList.activities.map {
            SavedActivity(name: $0.name, placeID: $0.placeID, address: $0.address)
        }
     
        return ActivityList(
            id: UUID(uuidString: firestoreList.id) ?? UUID(),
            name: firestoreList.name,
            activities: activities
        )
    }
}

// MARK: - Firestore Extension Methods
extension ActivityManager {

    // MARK: Update a list in Firestore
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
    
    /// Fetches all activity lists for the current user from Firestore.
    /// - Parameter completion: Closure called with an array of `ActivityList` objects.
    ///   Returns an empty array if the user has no lists or an error occurs.
    ///   -----------------------------------------------
    ///Adapted from: StackOverflow answer on fetching Firestore collections in Swift https://stackoverflow.com/questions/70864512/get-all-collections-that-are-declared-on-document-swift-firestore-firebase
    
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

    /// Clears the local cache and fetches all activity lists for the current user.
    /// Updates the `userLists` cache after fetching.
    /// - Parameter completion: Closure called with an array of `ActivityList` objects.
    func fetchUserListsForCurrentUser(completion: @escaping ([ActivityList]) -> Void) {
        resetListsForNewUser() // clear previous local lists first
        fetchUserLists { lists in
            self.userLists = lists
            completion(lists)
        }
    }

    
    /// Listens for incoming shared activity lists sent to the current user.
    /// Fires the `onReceive` closure whenever a new shared list is added.
    /// - Parameter onReceive: Closure called with a `FirestoreSharedList` object whenever a new shared list is detected.
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
