//
//  ProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//
//  Acknowledgements:
//
//  Libraries / Frameworks Used:
//  - Firebase Firestore (Apache 2.0 License) – for storing and fetching user profile data
//    https://firebase.google.com/docs/firestore
//  - Firebase Auth (Apache 2.0 License) – for user authentication and session management
//    https://firebase.google.com/docs/auth
//  - UIKit (Apple) – for building user interfaces
//    https://developer.apple.com/documentation/uikit
//
//  Icons / Images:
//  - SF Symbols (Apple) – used for placeholder profile images
//    https://developer.apple.com/sf-symbols/
//
//  Notes:
//  - User profile caching uses UserDefaults for quicker load times.
//  - Profile image is stored in Firestore as Base64 string and cached locally.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    /// Label displaying the user's display name with greeting
    @IBOutlet weak var NameOutlet: UILabel!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var userEmailOutlet: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let db = Firestore.firestore()
    private var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        
        /// Listen for profile updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(profileUpdated),
                                               name: Notification.Name("ProfileUpdated"),
                                               object: nil)
    }

    // MARK: - Lifecycle
    /// Called after the controller's view is loaded into memory
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }
    
    // MARK: Logout
    /// Logs out the current user and resets root view to login screen
    @IBAction func didTapLogout(_ sender: UIButton) {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = delegate.window as? UIWindow {
    
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
            }
        }
    

    /// Handler for profile update notifications
    @objc private func profileUpdated() {
        loadUserProfile()
    }

    /// Configures profile image view with circular mask and content mode
    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    /// Loads user profile from local cache first, then fetches latest from Firestore
    private func loadUserProfile() {
        guard !currentUID.isEmpty else {
            /// Fallback if user not logged in
            NameOutlet.text = "Hi User"
            userNameOutlet.text = "No username"
            userEmailOutlet.text = "No email"
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
            return
        }

        ///Load cached data first
        let cachedDisplayName = UserDefaults.standard.string(forKey: "displayName_\(currentUID)") ?? ""
        let cachedUsername = UserDefaults.standard.string(forKey: "userID_\(currentUID)") ?? ""
        let cachedEmail = UserDefaults.standard.string(forKey: "userEmail_\(currentUID)") ?? ""
        let cachedImageData = UserDefaults.standard.data(forKey: "profileImageData_\(currentUID)")

        NameOutlet.text = cachedDisplayName.isEmpty ? "Hi User" : "Hi \(cachedDisplayName)"
        userNameOutlet.text = cachedUsername.isEmpty ? "No username" : cachedUsername
        userEmailOutlet.text = cachedEmail.isEmpty ? "No email" : cachedEmail
        if let data = cachedImageData {
            profileImageView.image = UIImage(data: data)
        } else {
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
        }

        /// Fetch latest from Firestore
        db.collection("users").document(currentUID).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }

            let displayName = data["displayName"] as? String ?? ""
            let username = data["userID"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.NameOutlet.text = displayName.isEmpty ? "Hi User" : "Hi \(displayName)"
                self.userNameOutlet.text = username.isEmpty ? "No username" : username
                self.userEmailOutlet.text = email.isEmpty ? "No email" : email

                /// Cache locally
                UserDefaults.standard.set(displayName, forKey: "displayName_\(self.currentUID)")
                UserDefaults.standard.set(username, forKey: "userID_\(self.currentUID)")
                UserDefaults.standard.set(email, forKey: "userEmail_\(self.currentUID)")

                /// Load profile image from Base64 if exists
                if let base64 = data["profileImageBase64"] as? String,
                   let imageData = Data(base64Encoded: base64) {
                    self.profileImageView.image = UIImage(data: imageData)
                    UserDefaults.standard.set(imageData, forKey: "profileImageData_\(self.currentUID)")
                } else if cachedImageData == nil {
                    // Show placeholder if no image exists
                    self.profileImageView.image = UIImage(systemName: "person.and.background.dotted")
                }
            }
        }
    }
}
