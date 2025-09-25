//
//   ProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//



import UIKit
import CoreLocation

import UIKit
import CoreLocation

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var LogoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        // Example logout logic — replace with your actual auth/session clearing
        print("Logout tapped")
        
        // If using UserDefaults for login state
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // Navigate back to login screen
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? UIWindowSceneDelegate,
           let window = delegate.window as? UIWindow {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
}
