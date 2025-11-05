


import Foundation
import FirebaseFirestore

struct FirestoreActivityList: Codable {
    let id: String
    var name: String
    var ownerUID: String
    var sharedFromUID: String?
    var timestamp: Date
    var activities: [FirestoreActivityItem]

    // MARK: - Designated Init
    init(id: String, name: String, ownerUID: String, sharedFromUID: String? = nil, timestamp: Date, activities: [FirestoreActivityItem]) {
        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = sharedFromUID
        self.timestamp = timestamp
        self.activities = activities
    }

    // MARK: - Init from Firestore Document
    init?(from data: [String: Any], id: String) {
        guard let name = data["name"] as? String,
              let ownerUID = data["ownerUID"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let activitiesData = data["activities"] as? [[String: Any]] else {
            return nil
        }

        self.id = id
        self.name = name
        self.ownerUID = ownerUID
        self.sharedFromUID = data["sharedFromUID"] as? String
        self.timestamp = timestamp.dateValue()
        self.activities = activitiesData.compactMap { FirestoreActivityItem(from: $0) }
    }

    // MARK: - Convert to Dictionary for Firestore
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "ownerUID": ownerUID,
            "sharedFromUID": sharedFromUID as Any,
            "timestamp": Timestamp(date: timestamp),
            "activities": activities.map { $0.toDict() }
        ]
    }
}
