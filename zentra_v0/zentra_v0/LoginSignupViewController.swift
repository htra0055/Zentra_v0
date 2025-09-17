//
//  LoginSignupViewController.swift
//  FIT3178-W04-Lab
//
//  Created by Evelyn Tran on 7/9/2025.
//

import UIKit
import FirebaseAuth

class LoginSignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signupTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showAlert(title: "Missing Fields", message: "Please enter both email and password.")
                return
            }
            
            guard isValidEmail(email) else {
                showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                return
            }

//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                self.showAlert(title: "Signup Error", message: error.localizedDescription)
//                return
//            }
//
//            if let user = authResult?.user {
//                let appDelegate = UIApplication.shared.delegate as? AppDelegate
//                (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)
//            }
//
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "showMainApp", sender: nil)
//            }
//        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showAlert(title: "Signup Error", message: "This email is already registered. Please log in instead.")
                } else {
                    self.showAlert(title: "Signup Error", message: error.localizedDescription)
                }
                return
            }
            
            // Success: user is now created
            if let user = Auth.auth().currentUser {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Congratulations",
                        message: "Your new account is now set up:\n\(user.email ?? "")"
                    )
                }
            }

            
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "showMainApp", sender: nil)
//            }
        }


        
        
    }

            // Only login to use
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showAlert(title: "Missing Fields", message: "Please enter both email and password.")
                return
            }
            
            guard isValidEmail(email) else {
                showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                return
            }

//            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                if let error = error {
//                    self.showAlert(title: "Login Error", message: error.localizedDescription)
//                    return
//                }
//
//                // Navigate to next screen
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: "showMainApp", sender: nil)
//                }
//            }
        
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Login Error", message: error.localizedDescription)
                return
            }

            if let user = authResult?.user {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showMainApp", sender: nil)
            }
        }
        
        
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        if let firebaseController = (UIApplication.shared.delegate as? AppDelegate)?.databaseController as? FirebaseController {
            firebaseController.logout { error in
                if let error = error {
                    print("Logout failed: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }

    
}
