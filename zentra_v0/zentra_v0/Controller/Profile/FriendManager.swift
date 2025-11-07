//
//  FriendManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

// Acknowledgements:
//
// Libraries & SDKs:
// - Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore
// - Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth
// - Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//
import FirebaseFirestore
import FirebaseAuth

/// Singleton manager for handling friend-related operations, including sharing activities.
class FriendManager {
    
    /// Shared singleton instance
    static let shared = FriendManager()
    
    /// Private initializer to enforce singleton usage
    private init() {}
    

    // MARK: - Activity Sharing
      
      /**
       Shares a list of activities with a specified friend.
       
       - Parameters:
          - activities: An array of `MockPlace` objects representing the activities to share.
          - friend: The `User` object representing the friend to share activities with.
       
       The function determines the friend's Firestore document using `userID`, `email`, or `uid` in that order.
       It then adds a new document in the friend's `sharedActivities` subcollection containing:
       - The current user's UID as `fromUserId`
       - The list of activities with name and address
       - A timestamp of when the activities were shared
       
       Errors encountered during Firestore queries or document updates are logged to the console.
       */
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
