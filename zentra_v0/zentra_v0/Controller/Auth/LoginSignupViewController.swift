//
//  LoginSignupViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 18/9/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginSignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Signup
//    @IBAction func signupTapped(_ sender: UIButton) {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            showAlert(title: "Missing Fields", message: "Please enter both email and password.")
//            return
//        }
//
//        guard isValidEmail(email) else {
//            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
//            return
//        }
//
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error as NSError? {
//                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
//                    self.showAlert(title: "Signup Error", message: "This email is already registered. Please log in instead.")
//                } else {
//                    self.showAlert(title: "Signup Error", message: error.localizedDescription)
//                }
//                return
//            }
//
//            // Success: user created
//            if let user = authResult?.user {
//                let baseUserDoc: [String: Any] = [
//                    "uid": user.uid,
//                    "email": user.email ?? "",
//                    "name": user.displayName ?? ""
//                ]
//
//                self.db.collection("users").document(user.uid).setData(baseUserDoc) { error in
//                    if let error = error {
//                        print("Error saving base user to Firestore: \(error)")
//                    } else {
//                        print("Base user document created for \(user.uid)")
//                    }
//                }
//
//                // Ask user if they want to add a custom user ID
//                self.promptForCustomUserID(for: user)
//            }
//        }
//    }

    
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
                let db = Firestore.firestore()
                
                // Store basic info
                let userDoc: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "name": user.displayName ?? "",
                    "friends": []
                ]
                
                db.collection("users").document(user.uid).setData(userDoc) { error in
                    if let error = error {
                        print("Error saving user to Firestore: \(error.localizedDescription)")
                    }
                }

                // Prompt for optional userID
                self.promptForUserID(for: user)
            }
        }
    }

    // MARK: - Optional UserID Prompt
    private func promptForUserID(for user: FirebaseAuth.User) {
        let alert = UIAlertController(title: "Set a User ID (optional)",
                                      message: "Your friends can add you quickly using this ID. Leave empty to skip.",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Enter user ID" }
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: { _ in
            self.showHomePage()
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            let userID = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let userID = userID, !userID.isEmpty {
                Firestore.firestore().collection("users").document(user.uid).updateData(["userID": userID]) { error in
                    if let error = error {
                        print("Error saving userID: \(error.localizedDescription)")
                    }
                    self.showHomePage()
                }
            } else {
                self.showHomePage()
            }
        }))
        present(alert, animated: true)
    }

    // MARK: - Navigate to Home
    private func showHomePage() {
        DispatchQueue.main.async {
            if let homeTabBar = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBar") {
                homeTabBar.modalPresentationStyle = .fullScreen
                self.present(homeTabBar, animated: true)
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
            
            //  Clear previous user's lists
            ActivityManager.shared.resetListsForNewUser()

            // Fetch current user's lists from Firestore
            ActivityManager.shared.fetchUserLists { lists in
                print("Loaded \(lists.count) lists for current user")
            }

            if let user = authResult?.user {
                self.db.collection("users").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists {
                        print("User loaded:", document.data() ?? [:])
                    } else {
                        let userDoc: [String: Any] = [
                            "uid": user.uid,
                            "email": user.email ?? "",
                            "name": user.displayName ?? ""
                        ]
                        self.db.collection("users").document(user.uid).setData(userDoc)
                    }
                }

                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)

                DispatchQueue.main.async {
                    if let homeTabBar = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBar") {
                        homeTabBar.modalPresentationStyle = .fullScreen
                        self.present(homeTabBar, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - Custom UserID Prompt
    func promptForCustomUserID(for user: FirebaseAuth.User) {
        let alert = UIAlertController(
            title: "Create a User ID (Optional)",
            message: "You can add a short ID so friends can find you easily. You can skip this and add one later in your profile.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter a user ID (e.g. evelyn_tran)"
        }

        let skipAction = UIAlertAction(title: "Skip", style: .cancel) { _ in
            self.finishSignup(for: user)
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let customID = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !customID.isEmpty {
                // Save userID to Firestore
                self.db.collection("users").document(user.uid).updateData([
                    "userID": customID
                ]) { error in
                    if let error = error {
                        print("Error saving custom userID: \(error)")
                    } else {
                        print("Custom userID saved:", customID)
                    }
                    self.finishSignup(for: user)
                }
            } else {
                self.finishSignup(for: user)
            }
        }

        alert.addAction(skipAction)
        alert.addAction(saveAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    // MARK: - Finish Signup
    func finishSignup(for user: FirebaseAuth.User) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        (appDelegate?.databaseController as? FirebaseController)?.startDatabase(for: user)

        DispatchQueue.main.async {
            self.showAlert(
                title: "Account Created",
                message: "Your account is set up: \(user.email ?? "")",
                completion: {
                    if let homeTabBar = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBar") {
                        homeTabBar.modalPresentationStyle = .fullScreen
                        self.present(homeTabBar, animated: true)
                    }
                }
            )
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
