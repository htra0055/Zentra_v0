//
//  CustomiseProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 6/11/2025.

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CustomiseProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        setupTextFields()
        loadUserProfile()
    }

    private func loadUserProfile() {
        // Load cached
        nameTextField.text = UserDefaults.standard.string(forKey: "displayName_\(currentUID)")
        if let imageData = UserDefaults.standard.data(forKey: "profileImageData_\(currentUID)") {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
        }
    }

    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
    }

    @objc private func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func setupTextFields() {
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
    }

    @IBAction func saveChangesButton(_ sender: Any) {
        guard !currentUID.isEmpty else {
            print(" No user logged in.")
            return
        }
        guard let displayName = nameTextField.text else { return }

        var updateData: [String: Any] = ["displayName": displayName]

        if let image = profileImageView.image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = storage.reference().child("profileImages/\(currentUID).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if error == nil {
                    storageRef.downloadURL { url, _ in
                        if let url = url {
                            updateData["profileImageURL"] = url.absoluteString
                        }
                        self.updateFirestoreAndCache(updateData: updateData, displayName: displayName, imageData: imageData)
                    }
                } else {
                    print("Image upload failed:", error?.localizedDescription ?? "")
                }
            }
        } else {
            updateFirestoreAndCache(updateData: updateData, displayName: displayName, imageData: nil)
        }
    }

    private func updateFirestoreAndCache(updateData: [String: Any], displayName: String, imageData: Data?) {
        guard !currentUID.isEmpty else {
            print(" No user UID found.")
            return
        }

        db.collection("users").document(currentUID).setData(updateData, merge: true) { error in
            if let error = error {
                print("Error updating profile:", error.localizedDescription)
            } else {
                print(" Profile created/updated successfully.")
            }
        }

        UserDefaults.standard.set(displayName, forKey: "displayName_\(currentUID)")
        if let data = imageData {
            UserDefaults.standard.set(data, forKey: "profileImageData_\(currentUID)")
        }

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - UIImagePicker
extension CustomiseProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let edited = info[.editedImage] as? UIImage {
            profileImageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            profileImageView.image = original
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CustomiseProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
