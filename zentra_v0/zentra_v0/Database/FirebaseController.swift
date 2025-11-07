//
//  FirebaseController.swift
//  FIT3178-W04-Lab
//
//  Created by Evelyn Tran on 7/9/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Firebase Core (Apache 2.0 License) – https://firebase.google.com/docs/reference/ios/firebasecore/api/reference/Classes
// - Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth/ios/start
// - Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore/quickstart
//
// Purpose:
// Provides a centralized controller for handling Firebase authentication and Firestore database access.
// Supports initializing Firebase, managing the current user, starting database sessions, and logging out.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// `FirebaseController` is a singleton-style utility class that handles Firebase initialization,
/// authentication, and Firestore database access. It abstracts common Firebase operations for easier usage ac
class FirebaseController: NSObject {

    // MARK: - Properties
      
    /// The Firebase Auth controller instance for authentication tasks.
    var authController: Auth
    
    /// The Firestore database instance for data storage and retrieval.
    var database: Firestore
    
    /// The currently authenticated Firebase user (if any).
    var currentUser: FirebaseAuth.User?

    // MARK: - Initialization
     /**
      Initializes Firebase app, sets up Auth and Firestore instances.
      */
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        super.init()
    }

    // MARK: - Methods
     /**
      Starts a database session for the specified user.
      
      - Parameter user: The authenticated Firebase user.
      */
    func startDatabase(for user: FirebaseAuth.User) {
        self.currentUser = user
    }

    /**
       Logs out the current user and clears the session.
       
       - Parameter completion: Closure called with an optional error if logout fails.
       */
    func logout(completion: @escaping (Error?) -> Void) {
        do {
            try authController.signOut()
            currentUser = nil
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
}

