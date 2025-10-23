//
//  FirestoreActivityList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//

import Foundation
import FirebaseFirestore


struct FirestoreActivityItem: Codable {
    let name: String
    let placeID: String
    let address: String
    let type: String? // optional Activity rawValue
}

struct FirestoreActivityList: Codable {
    let id: String
    var name: String
    var ownerUID: String
    var sharedFromUID: String?
    var timestamp: Date
    var activities: [FirestoreActivityItem]

    // Proper memberwise initializer
    init(id: String, name: String, ownerUID: String, sharedFromUID: String? = nil, timestamp: Date, activities: [FirestoreActivityItem]) {
        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = sharedFromUID
        self.timestamp = timestamp
        self.activities = activities
    }

    // Failable initializer from Firestore document
    init?(from data: [String: Any], id: String) {
        guard let name = data["name"] as? String,
              let ownerUID = data["ownerUID"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let activitiesData = data["activities"] as? [[String: Any]] else { return nil }

        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = data["sharedFromUID"] as? String
        self.timestamp = timestamp.dateValue()
        self.activities = activitiesData.compactMap { dict in
            FirestoreActivityItem(
                name: dict["name"] as? String ?? "",
                placeID: dict["placeID"] as? String ?? "",
                address: dict["address"] as? String ?? "",
                type: dict["type"] as? String
            )
        }
    }

    // Convert to dictionary for Firestore
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "ownerUID": ownerUID,
            "sharedFromUID": sharedFromUID as Any,
            "timestamp": Timestamp(date: timestamp),
            "activities": activities.map { [
                "name": $0.name,
                "placeID": $0.placeID,
                "address": $0.address,
                "type": $0.type as Any
            ]}
        ]
    }
}
