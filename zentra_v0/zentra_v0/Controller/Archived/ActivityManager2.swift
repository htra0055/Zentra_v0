////
////  ActivityManager.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 7/10/2025.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//import GooglePlaces
//
//
//// MARK: - Activity Manager
//class ActivityManager {
//    static let shared = ActivityManager()
//    private init() {}
//
//    private var userLists: [ActivityList] = []
//
//    // MARK: - Public API
//    func getUserLists() -> [ActivityList] {
//        return userLists
//    }
//
//    // MARK: - Create New List
//    func createList(name: String, completion: @escaping (Error?, UUID?) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let docRef = Firestore.firestore().collection("activityLists").document()
//        let firestoreList = FirestoreActivityList(
//            id: docRef.documentID,
//            name: name,
//            ownerUID: uid,
//            sharedFromUID: nil,
//            timestamp: Date(),
//            activities: []
//        )
//
//        docRef.setData(firestoreList.toDict()) { error in
//            let localUUID = UUID(uuidString: docRef.documentID) ?? UUID()
//            if error == nil {
//                let newList = ActivityList(id: localUUID, name: name, activities: [])
//                self.userLists.append(newList)
//            }
//            completion(error, localUUID)
//        }
//    }
//
//    // MARK: - Add Activity
//    func addActivity(place: GMSPlace, toList list: ActivityList, completion: ((Error?) -> Void)? = nil) {
//        guard let _ = Auth.auth().currentUser?.uid else { return }
//        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }
//
//        let activity = SavedActivity(
//            name: place.name ?? "Unknown Place",
//            placeID: place.placeID ?? "",
//            address: place.formattedAddress ?? ""
//        )
//
//        userLists[index].activities.append(activity)
//        updateListInFirestore(userLists[index], completion: completion)
//    }
//
//    // MARK: - Update List in Firestore
//    func updateListInFirestore(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
//        let firestoreList = convertToFirestore(list)
//        Firestore.firestore()
//            .collection("activityLists")
//            .document(firestoreList.id)
//            .setData(firestoreList.toDict(), completion: completion)
//    }
//
//    // MARK: - Delete List
//    func deleteList(_ list: ActivityList, completion: ((Error?) -> Void)? = nil) {
//        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
//            userLists.remove(at: index)
//        }
//
//        Firestore.firestore()
//            .collection("activityLists")
//            .document(list.id.uuidString)
//            .delete(completion: completion)
//    }
//
//    // MARK: - Convert List
//    func convertToFirestore(_ list: ActivityList) -> FirestoreActivityList {
//        let currentUID = Auth.auth().currentUser?.uid ?? ""
//        let firestoreActivities = list.activities.map {
//            FirestoreActivityItem(name: $0.name, placeID: $0.placeID, address: $0.address)
//        }
//        return FirestoreActivityList(
//            id: list.id.uuidString,
//            name: list.name,
//            ownerUID: currentUID,
//            sharedFromUID: nil,
//            timestamp: Date(),
//            activities: firestoreActivities
//        )
//    }
//
//    func convertToLocal(_ firestoreList: FirestoreActivityList) -> ActivityList {
//        let activities = firestoreList.activities.map {
//            SavedActivity(name: $0.name, placeID: $0.placeID, address: $0.address)
//        }
//        let uuid = UUID(uuidString: firestoreList.id) ?? UUID()
//        return ActivityList(id: uuid, name: firestoreList.name, activities: activities)
//    }
//
//    // MARK: - Fetch User Lists
//    func fetchUserLists(completion: @escaping ([ActivityList]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { completion([]); return }
//
//        Firestore.firestore().collection("activityLists")
//            .whereField("ownerUID", isEqualTo: uid)
//            .order(by: "timestamp", descending: true)
//            .getDocuments { snapshot, _ in
//                let lists = snapshot?.documents.compactMap { doc -> ActivityList? in
//                    guard let firestoreList = FirestoreActivityList(from: doc.data(), id: doc.documentID) else { return nil }
//                    return self.convertToLocal(firestoreList)
//                } ?? []
//                self.userLists = lists
//                completion(lists)
//            }
//    }
//
//    // MARK: - Reset Lists for New User
//    func resetListsForNewUser(completion: ((Error?) -> Void)? = nil) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion?(NSError(domain: "ActivityManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
//            return
//        }
//
//        Firestore.firestore()
//            .collection("activityLists")
//            .whereField("ownerUID", isEqualTo: uid)
//            .getDocuments { snapshot, error in
//                if let error = error { completion?(error); return }
//
//                let batch = Firestore.firestore().batch()
//                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
//
//                batch.commit(completion: completion)
//            }
//    }
//
//    // MARK: - Shared Lists
//    func listenForSharedLists(onReceive: @escaping (FirestoreSharedList) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        Firestore.firestore().collection("sharedActivities")
//            .document(uid)
//            .collection("sharedLists")
//            .addSnapshotListener { snapshot, _ in
//                snapshot?.documentChanges.forEach { change in
//                    if change.type == .added {
//                        if let sharedList = FirestoreSharedList(from: change.document.data(), id: change.document.documentID) {
//                            onReceive(sharedList)
//                        }
//                    }
//                }
//            }
//    }
//
//    func acceptSharedList(_ sharedList: FirestoreSharedList, completion: @escaping (Error?) -> Void) {
//        let newList = sharedList.toActivityList()
//        createList(name: newList.name) { error, newUUID in
//            if let error = error { completion(error); return }
//            guard let newUUID = newUUID else { return }
//
//            let firestoreList = FirestoreActivityList(
//                id: newUUID.uuidString,
//                name: newList.name,
//                ownerUID: Auth.auth().currentUser?.uid ?? "",
//                sharedFromUID: sharedList.fromUID,
//                timestamp: Date(),
//                activities: sharedList.activities
//            )
//
//            Firestore.firestore()
//                .collection("activityLists")
//                .document(newUUID.uuidString)
//                .setData(firestoreList.toDict()) { err in
//                    if let err = err { completion(err) }
//                    else {
//                        self.removeSharedList(sharedList)
//                        completion(nil)
//                    }
//                }
//        }
//    }
//
//    func removeSharedList(_ sharedList: FirestoreSharedList) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore()
//            .collection("sharedActivities")
//            .document(uid)
//            .collection("sharedLists")
//            .document(sharedList.id)
//            .delete()
//    }
//}
//
//struct PlaceData {
//    let name: String
//    let placeID: String
//    let address: String
//}
//
