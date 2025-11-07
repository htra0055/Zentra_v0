////
////  CustomiseProfileViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 6/11/2025.
//
//import UIKit
//import FirebaseFirestore
//
//class CustomiseProfileViewController: UIViewController {
//
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var yourbio: UITextView!
//    @IBOutlet weak var profileImageView: UIImageView!
//
//    let db = Firestore.firestore()
//    let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadUserProfile()
//        setupProfileImageView()
//        setupTextFields()
//    }
//
//    private func loadUserProfile() {
//        let defaults = UserDefaults.standard
//        nameTextField.text = defaults.string(forKey: "displayName") ?? ""
//        yourbio.text = defaults.string(forKey: "bio") ?? ""
//
//        if let imageData = defaults.data(forKey: "profileImage") {
//            profileImageView.image = UIImage(data: imageData)
//        } else {
//            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
//        }
//    }
//
//    private func setupProfileImageView() {
//        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
//        profileImageView.clipsToBounds = true
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.isUserInteractionEnabled = true
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
//        profileImageView.addGestureRecognizer(tapGesture)
//    }
//
//    @objc private func selectProfileImage() {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .photoLibrary
//        picker.allowsEditing = true
//        picker.modalPresentationStyle = .fullScreen
//        present(picker, animated: true)
//    }
//
//    private func setupTextFields() {
//        nameTextField.delegate = self
//        nameTextField.returnKeyType = .done
//        yourbio.delegate = self
//    }
//
//    // MARK: Save changes to Firebase & UserDefaults
//    @IBAction func saveChangesButton(_ sender: Any) {
//        guard let displayName = nameTextField.text, !displayName.isEmpty else {
//            showAlert(title: "Invalid Input", message: "Name cannot be empty.")
//            return
//        }
//
//        let bioText = yourbio.text ?? ""
//
//        // Save to UserDefaults
//        UserDefaults.standard.set(displayName, forKey: "displayName")
//        UserDefaults.standard.set(bioText, forKey: "bio")
//
//        if let image = profileImageView.image,
//           let imageData = image.jpegData(compressionQuality: 0.8) {
//            UserDefaults.standard.set(imageData, forKey: "profileImage")
//        }
//
//        // Save to Firestore
//        if !uid.isEmpty {
//            let userRef = db.collection("users").document(uid)
//            userRef.updateData([
//                "displayName": displayName,
//                "bio": bioText
//            ]) { error in
//                if let error = error {
//                    print("Error updating profile in Firestore: \(error)")
//                }
//            }
//        }
//
//        showAlert(title: "Saved", message: "Profile updated!") {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//            completion?()
//        })
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - Image Picker
//extension CustomiseProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let edited = info[.editedImage] as? UIImage {
//            profileImageView.image = edited
//        } else if let original = info[.originalImage] as? UIImage {
//            profileImageView.image = original
//        }
//        picker.dismiss(animated: true)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true)
//    }
//}
//
//// MARK: - UITextFieldDelegate
//extension CustomiseProfileViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}
//
//// MARK: - UITextViewDelegate
//extension CustomiseProfileViewController: UITextViewDelegate {}
//
