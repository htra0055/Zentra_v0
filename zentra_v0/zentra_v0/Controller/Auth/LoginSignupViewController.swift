

//
//  LoginSignupViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 18/9/2025.
//

// TODO: need a register page for signup button -> to save user info
// TODO: advanced: connect to google account/gmail/other authentication.



import UIKit
import FirebaseAuth

class LoginSignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Signup
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

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showAlert(title: "Signup Error", message: "This email is already registered. Please log in instead.")
                } else {
                    self.showAlert(title: "Signup Error", message: error.localizedDescription)
                }
                return
            }

            // Success: user created
            if let user = authResult?.user {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)
                
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Account Created",
                        message: "Your account is set up: \(user.email ?? "")",
                        completion: {
                           // self.performSegue(withIdentifier: "showHomePage", sender: nil)
                            if let homeTabBar = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBar") {
                                homeTabBar.modalPresentationStyle = .fullScreen
                                self.present(homeTabBar, animated: true)
                            }
                            
                            
                        }
                    )
                }
            }
        }
    }

    // MARK: - Login
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

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Login Error", message: error.localizedDescription)
                return
            }

            if let user = authResult?.user {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)
                
                
                DispatchQueue.main.async {
                    
                   // self.performSegue(withIdentifier: "showHomePage", sender: nil)
                    if let homeTabBar = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBar") {
                        homeTabBar.modalPresentationStyle = .fullScreen
                        self.present(homeTabBar, animated: true)}
                }

            }
        }
    }

    // MARK: - Helpers
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true)
    }
}
