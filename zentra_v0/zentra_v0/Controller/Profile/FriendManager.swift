//
//  FriendManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

import FirebaseFirestore
import FirebaseAuth

class FriendManager {
    static let shared = FriendManager()
    
    private init() {}
    
    // MARK: share function
    func shareActivities(_ activities: [MockPlace], with friend: User)

    {
        let db = Firestore.firestore()
        let activitiesData = activities.map { ["name": $0.name, "address": $0.address] }
        let usersRef = db.collection("users")
        
        
        let query: Query
        if let userID = friend.userID, !userID.isEmpty {
            query = usersRef.whereField("userID", isEqualTo: userID)
        } else if friend.email.contains("@") {
            query = usersRef.whereField("email", isEqualTo: friend.email)
        } else {
            query = usersRef.whereField("uid", isEqualTo: friend.uid)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error finding friend document: \(error.localizedDescription)")
                return
            }
            
            guard let doc = snapshot?.documents.first else {
                print("Friend not found in Firestore")
                return
            }
            
            usersRef.document(doc.documentID)
                .collection("sharedActivities")
                .addDocument(data: [
                    "fromUserId": Auth.auth().currentUser?.uid ?? "",
//                    "fromName": Auth.auth().currentUser?.displayName ?? "Friend",
//                    "listName": listName,
                    "activities": activitiesData,
                    "timestamp": Timestamp()
                ]) { error in
                    if let error = error {
                        print("Error sharing activities: \(error.localizedDescription)")
                    } else {
                        print("Activities shared successfully with \(friend.name ?? "Unknown")")
                    }
                }
        }
    }

}
