//
//   ProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var NameOutlet: UILabel!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var userEmailOutlet: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let db = Firestore.firestore()
    private var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        
        // Listen for profile updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(profileUpdated),
                                               name: Notification.Name("ProfileUpdated"),
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }
    
        // MARK: Logout
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
    

    @objc private func profileUpdated() {
        loadUserProfile()
    }

    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    private func loadUserProfile() {
        guard !currentUID.isEmpty else {
            // Fallback if user not logged in
            NameOutlet.text = "Hi User"
            userNameOutlet.text = "No username"
            userEmailOutlet.text = "No email"
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
            return
        }

        // Load cached data first
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

        // Fetch latest from Firestore
        db.collection("users").document(currentUID).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }

            let displayName = data["displayName"] as? String ?? ""
            let username = data["userID"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.NameOutlet.text = displayName.isEmpty ? "Hi User" : "Hi \(displayName)"
                self.userNameOutlet.text = username.isEmpty ? "No username" : username
                self.userEmailOutlet.text = email.isEmpty ? "No email" : email

                // Cache locally
                UserDefaults.standard.set(displayName, forKey: "displayName_\(self.currentUID)")
                UserDefaults.standard.set(username, forKey: "userID_\(self.currentUID)")
                UserDefaults.standard.set(email, forKey: "userEmail_\(self.currentUID)")

                // Load profile image from Base64 if exists
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
