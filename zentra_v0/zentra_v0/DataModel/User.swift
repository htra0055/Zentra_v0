//
//  User.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//
//  Purpose:
//  Represents a user in the application, including optional display name and userID.
//  Supports initialization from Firestore data dictionaries or direct parameters.
//
//  Dependencies:
//  - Foundation
//

import Foundation

/// Represents an application user with authentication and optional profile metadata.
struct User: Codable {
    
    /// Firebase Authentication UID for the user.
    let uid: String
    
    /// User's email address.
    let email: String
    
    /// Optional display name of the user.
    var name: String?
    
    /// Optional custom userID for app-specific identification.
    var userID: String?
    
    // MARK: - Initialization
    
    /// Initializes a `User` from a Firestore data dictionary.
    /// - Parameter data: Firestore document data dictionary.
    /// - Returns: A `User` instance if required fields (`uid` and `email`) are present; otherwise `nil`.
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

    /// Initializes a `User` directly with given properties.
    /// - Parameters:
    ///   - uid: Firebase Authentication UID.
    ///   - email: Email address of the user.
    ///   - name: Optional display name.
    ///   - userID: Optional app-specific user ID.
    init(uid: String, email: String, name: String? = nil, userID: String? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        self.userID = userID
    }
}
