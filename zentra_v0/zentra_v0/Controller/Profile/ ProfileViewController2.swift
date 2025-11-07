//
//   ProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var yourbio: UITextView!
    @IBOutlet weak var NameOutlet: UILabel!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var userEmailOutlet: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var readMeButton: UIButton!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }

    // MARK: Load profile info
    private func loadUserProfile() {
        let defaults = UserDefaults.standard

        userNameOutlet.text = defaults.string(forKey: "userName") ?? "No Username"
        userEmailOutlet.text = defaults.string(forKey: "userEmail") ?? "No Email"
        
        NameOutlet.text = defaults.string(forKey: "displayName") ?? "Hi \(userNameOutlet.text ?? "")"
        yourbio.text = defaults.string(forKey: "bio") ?? ""

        if let imageData = defaults.data(forKey: "profileImage") {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
        }
    }

    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
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

    // MARK: Navigate to customise profile
    @IBAction func didTapEditProfile(_ sender: UIButton) {
    }
}
