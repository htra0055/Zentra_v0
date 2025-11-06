//
//   ProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

// TODO: Can edit name, show userid, show email + add profile photo + weather + read me acknowledge function


import UIKit
import CoreLocation


class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var userEmailOutlet: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var readMeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make profile image round
              profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
              profileImageView.clipsToBounds = true
              profileImageView.contentMode = .scaleAspectFill
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           // Load name & email
           userNameOutlet.text = UserDefaults.standard.string(forKey: "userName") ?? "No Name"
           userEmailOutlet.text = UserDefaults.standard.string(forKey: "userEmail") ?? "No Email"
           
           // Load profile image
           if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
               profileImageView.image = UIImage(data: imageData)
           } else {
               profileImageView.image = UIImage(systemName: "person.and.background.dotted")
           }
           
           // Update Read Me button
           let acknowledged = UserDefaults.standard.bool(forKey: "readMeAcknowledged")
           readMeButton.setTitle(acknowledged ? "Acknowledged " : "Read Me", for: .normal)
       }
    

    
    @IBAction func didTapLogout(_ sender: UIButton) {
      
        print("Logout tapped")

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
    
    
       @IBAction func didTapReadMe(_ sender: UIButton) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let readMeVC = storyboard.instantiateViewController(withIdentifier: "ReadMeViewController")
//           navigationController?.pushViewController(readMeVC, animated: true)
       }
       
       @IBAction func didTapEditProfile(_ sender: UIButton) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           let customiseVC = storyboard.instantiateViewController(withIdentifier: "CustomiseProfileViewController")
//           navigationController?.pushViewController(customiseVC, animated: true)
       }
}
