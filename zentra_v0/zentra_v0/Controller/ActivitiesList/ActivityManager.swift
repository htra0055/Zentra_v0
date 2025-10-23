//
//  ActivityManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//


import Foundation
import GooglePlaces
import UIKit
import MapKit



// MARK: - Saved Activity Model
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

// MARK: - Saved Activity List
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

    private var userLists: [ActivityList] = []

    private init() {
        loadLists()
    }

    // MARK: - Persistence
    private func saveLists() {
        if let data = try? JSONEncoder().encode(userLists) {
            UserDefaults.standard.set(data, forKey: "userLists")
        }
    }

    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "userLists"),
           let decoded = try? JSONDecoder().decode([ActivityList].self, from: data) {
            userLists = decoded
        }
    }

    // MARK: - Public API

    func getUserLists() -> [ActivityList] {
        return userLists
    }

    @discardableResult
    func createList(name: String) -> ActivityList {
        let newList = ActivityList(name: name)
        userLists.append(newList)
        saveLists()
        return newList
    }

    func addActivity(place: GMSPlace, toList list: ActivityList) {
        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }
        let activity = SavedActivity(
            name: place.name ?? "Unknown Place",
            placeID: place.placeID ?? "",
            address: place.formattedAddress ?? ""
        )
        userLists[index].activities.append(activity)
        saveLists()
    }

    func saveActivities(places: [GMSPlace]) {
        let defaultListName = "Saved Activities"
        if !userLists.contains(where: { $0.name == defaultListName }) {
            createList(name: defaultListName)
        }
        guard let list = userLists.first(where: { $0.name == defaultListName }) else { return }
        for place in places {
            addActivity(place: place, toList: list)
        }
    }
    
    func updateList(_ list: ActivityList) {
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists[index] = list
            saveLists()   // Persist changes
        }
    }
    
    func deleteList(_ list: ActivityList) {
        // Remove from local array
        userLists.removeAll { $0.id == list.id }
        
        // Persist the change
        saveLists()   // <-- use the existing saveLists() method
    }

    func saveMKMapItem(_ item: MKMapItem) {
        let defaultListName = "Saved Activities"
        
        // Create default list if it doesn't exist
        if !userLists.contains(where: { $0.name == defaultListName }) {
            createList(name: defaultListName)
        }
        
        guard let list = userLists.first(where: { $0.name == defaultListName }) else { return }
        
        let activity = SavedActivity(
            name: item.name ?? "Unknown Place",
            placeID: UUID().uuidString,
            address: item.placemark.title ?? ""
        )
        
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists[index].activities.append(activity)
            saveLists() // Persist changes
        }
    }

    
}

extension ActivityManager {
    
    func addMKMapItemToList(_ item: MKMapItem, list: ActivityList) {
        let activity = SavedActivity(
            name: item.name ?? "Unknown Place",
            placeID: UUID().uuidString, // or some unique identifier
            address: item.placemark.title ?? ""
        )
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists[index].activities.append(activity)
            saveLists()
        }
    }
    
    func saveMKMapItemToDefaultList(_ item: MKMapItem) {
        let defaultListName = "Saved Activities"
        if let list = userLists.first(where: { $0.name == defaultListName }) {
            addMKMapItemToList(item, list: list)
        } else {
            let list = createList(name: defaultListName)
            addMKMapItemToList(item, list: list)
        }
    }
}

// MARK: - Firestore Conversion & Sync
extension ActivityManager {

    // Convert local ActivityList -> FirestoreActivityList
    func convertToFirestore(_ list: ActivityList, sharedFromUID: String? = nil) -> FirestoreActivityList {
        let currentUID = Auth.auth().currentUser?.uid ?? list.id.uuidString
        let firestoreActivities = list.activities.map {
            FirestoreActivityItem(name: $0.name, placeID: $0.placeID, address: $0.address, type: nil)
        }
        return FirestoreActivityList(
            from: <#[String : Any]#>, id: UUID().uuidString,
            name: list.name,
            ownerUID: currentUID,
            sharedFromUID: sharedFromUID,
            timestamp: Date(),
            activities: firestoreActivities
        ) ?? <#default value#>
    }

    // Convert FirestoreActivityList -> local ActivityList
    func convertToLocal(_ firestoreList: FirestoreActivityList) -> ActivityList {
        let activities = firestoreList.activities.map {
            SavedActivity(name: $0.name, placeID: $0.placeID, address: $0.address)
        }
        return ActivityList(name: firestoreList.name, activities: activities)
    }

    // Save list to Firestore
    func saveListToFirestore(_ list: ActivityList, sharedFromUID: String? = nil, completion: ((Error?) -> Void)? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let firestoreList = convertToFirestore(list, sharedFromUID: sharedFromUID)

        db.collection("users").document(currentUID)
            .collection("activityLists").document(firestoreList.id)
            .setData(firestoreList.toDict()) { error in
                completion?(error)
            }
    }

    // Fetch user lists from Firestore
    func fetchUserListsFromFirestore(completion: @escaping ([FirestoreActivityList]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else { completion([]); return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUID)
            .collection("activityLists")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { completion([]); return }
                let lists = docs.compactMap { FirestoreActivityList(from: $0.data(), id: $0.documentID) }
                completion(lists)
            }
    }

    // Add a shared list to the user
    func addSharedListToUser(_ sharedList: FirestoreActivityList, completion: ((Error?) -> Void)? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        var listDict = sharedList.toDict()
        listDict["sharedFromUID"] = sharedList.ownerUID

        db.collection("users").document(currentUID)
            .collection("activityLists").document()
            .setData(listDict) { error in
                completion?(error)
            }
    }
}
