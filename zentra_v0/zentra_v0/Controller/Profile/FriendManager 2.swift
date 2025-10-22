//
//  FriendManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//


import Foundation
import GooglePlaces

//class FriendManager {
//    static let shared = FriendManager()
//
//    private var friends: [String] = ["alice@example.com", "bob@example.com", "carol@example.com"]
//    private var sharedActivities: [String: [GMSPlace]] = [:] // friendEmail : activities
//
//    func getFriends() -> [String] {
//        return friends
//    }
//
//    func addFriend(_ email: String) {
//        guard !friends.contains(email) else { return }
//        friends.append(email)
//    }
//
//    func shareActivities(_ activities: [GMSPlace], with friend: String) {
//        if sharedActivities[friend] == nil {
//            sharedActivities[friend] = []
//        }
//        sharedActivities[friend]?.append(contentsOf: activities)
//        print("Shared \(activities.count) activities with \(friend)")
//    }
//
//    func getSharedActivities(for friend: String) -> [GMSPlace] {
//        return sharedActivities[friend] ?? []
//    }
//}


import FirebaseFirestore
import FirebaseAuth

class FriendManager {
    static let shared = FriendManager()
    
    private init() {}
    
    func shareActivities(_ activities: [MockPlace], with friend: User) {
        let db = Firestore.firestore() // <- initialize Firestore
        
        // Convert activities into a dictionary array
        let activitiesData = activities.map { ["name": $0.name, "address": $0.address] }
        
        db.collection("users")
          .document(friend.id) // friend’s user ID in Firestore
          .collection("sharedActivities")
          .addDocument(data: [
              "fromUserId": Auth.auth().currentUser?.uid ?? "",
              "activities": activitiesData,
              "timestamp": Timestamp()
          ]) { error in
              if let error = error {
                  print("Error sharing activities: \(error.localizedDescription)")
              } else {
                  print("Activities shared successfully with \(friend.name)")
              }
          }
    }
}
