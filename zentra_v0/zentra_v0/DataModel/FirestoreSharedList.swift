//
//  FirestoreSharedList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 5/11/2025.
//


import Foundation
import FirebaseFirestore

struct FirestoreSharedList {
    let id: String
    let fromUID: String
    let fromName: String
    let listName: String
    let activities: [SharedActivityItem] // similar to MockPlace
    let timestamp: Date
    
    init?(from dict: [String: Any], id: String) {
        guard let fromUID = dict["fromUID"] as? String,
              let fromName = dict["fromName"] as? String,
              let listName = dict["listName"] as? String,
              let activitiesArray = dict["activities"] as? [[String: Any]],
              let timestamp = dict["timestamp"] as? Timestamp
        else { return nil }
        
        self.id = id
        self.fromUID = fromUID
        self.fromName = fromName
        self.listName = listName
        self.timestamp = timestamp.dateValue()
        self.activities = activitiesArray.compactMap { SharedActivityItem(from: $0) }
    }
    
    func toActivityList() -> ActivityList {
        let savedActivities = activities.map { SavedActivity(name: $0.name, placeID: "", address: $0.address) }
        return ActivityList(name: listName, activities: savedActivities)
    }
}

struct SharedActivityItem {
    let name: String
    let address: String
    
    init?(from dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let address = dict["address"] as? String else { return nil }
        self.name = name
        self.address = address
    }
    
    func toDict() -> [String: Any] {
        return ["name": name, "address": address]
    }
}
