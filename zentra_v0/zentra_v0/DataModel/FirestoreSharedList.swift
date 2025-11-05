//
//  FirestoreSharedList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 5/11/2025.
//

import Foundation
import FirebaseFirestore

struct FirestoreSharedList: Codable {
    let id: String
    let fromUID: String
    let fromName: String
    let listName: String
    let timestamp: Date
    let activities: [FirestoreActivityItem]
    let sharedFromName: String?

    // MARK: - Init from Firestore
    init?(from data: [String: Any], id: String) {
        guard let fromUID = data["fromUID"] as? String,
              let fromName = data["fromName"] as? String,
              let listName = data["listName"] as? String,
              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
              let activitiesData = data["activities"] as? [[String: Any]] else {
            return nil
        }

        self.id = id
        self.fromUID = fromUID
        self.fromName = fromName
        self.listName = listName
        self.timestamp = timestamp
        self.activities = activitiesData.compactMap { FirestoreActivityItem(from: $0) }
        self.sharedFromName = data["sharedFromName"] as? String
    }
    

    // MARK: - Convert to Local ActivityList
    func toActivityList() -> ActivityList {
        let converted = activities.map {
            SavedActivity(name: $0.name, placeID: $0.placeID, address: $0.address)
        }
        return ActivityList(name: listName, activities: converted)
    }
}


