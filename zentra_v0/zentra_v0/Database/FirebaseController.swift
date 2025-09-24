//
//  FirebaseController.swift
//  FIT3178-W04-Lab
//
//  Created by Evelyn Tran on 7/9/2025.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject {

    var authController: Auth
    var database: Firestore
    var currentUser: FirebaseAuth.User?

    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        super.init()
    }

    func startDatabase(for user: FirebaseAuth.User) {
        self.currentUser = user
        // Any user-specific collection setup can go here
    }

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

