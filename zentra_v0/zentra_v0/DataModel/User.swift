//
//  User.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//


import Foundation

struct User: Codable {
    let uid: String          // Firebase Auth UID
    let email: String
    var name: String?
    var userID: String?
    
    // MARK: Initialize from Firestore data dictionary
    init?(from data: [String: Any]) {
        guard let uid = data["uid"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        self.uid = uid
        self.email = email
        self.name = data["name"] as? String
        self.userID = data["userID"] as? String
    }

    // MARK: Initialize directly
    init(uid: String, email: String, name: String? = nil, userID: String? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        self.userID = userID
    }
}
