//
//  CustomiseProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 6/11/2025.

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: Class
/// Controller to customise the user's profile including display name and profile image.
/// Supports caching to UserDefaults and saving updates to Firestore.
/// Notifies `ProfileViewController` when changes occur.
class CustomiseProfileViewController: UIViewController {

    // MARK: Outlet
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    // MARK: - Properties
    /// Firestore database reference
    private let db = Firestore.firestore()
    private var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    // MARK: - Lifecycle
    /// Called after the controller's view is loaded. Sets up UI and loads cached profile.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        setupTextFields()
        loadUserProfile()
        makeProfileImageCircular()
    }


    // MARK: - Load Profile
    /// Loads user profile from local cache (UserDefaults) and sets initial UI values.
    private func loadUserProfile() {
        nameTextField.text = UserDefaults.standard.string(forKey: "displayName_\(currentUID)")
        if let imageData = UserDefaults.standard.data(forKey: "profileImageData_\(currentUID)") {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
        }
    }

    // MARK: - Setup
    /// Configures profile image view appearance and gesture recognizer for selecting a new image
    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
    }
    
    /// Ensures profile image is circular and clipped correctly
    private func makeProfileImageCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    /// Configures text fields (delegate and return key)
    @objc private func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    // MARK: - Image Selection
    /// Opens UIImagePickerController to allow user to select a new profile image
    private func setupTextFields() {
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
    }

    // MARK: - Save Changes
    /// Saves the display name and profile image to Firestore
    /// Converts the image to Base64 before saving
    /// Updates local cache and notifies `ProfileViewController` to reload
    @IBAction func saveChangesButton(_ sender: Any) {
        guard let displayName = nameTextField.text?.trimmingCharacters(in: .whitespaces), !displayName.isEmpty else {
            showAlert(title: "Invalid Name", message: "Please enter a valid display name.")
            return
        }
        var updateData: [String: Any] = ["displayName": displayName]
        var imageData: Data? = nil

        if let image = profileImageView.image,
           let resized = image.resized(toMax: 512),
           let data = resized.jpegDataCompressed(quality: 0.7) {
            let base64String = data.base64EncodedString()
            updateData["profileImageBase64"] = base64String
            imageData = data
        }
        
        db.collection("users").document(currentUID).updateData(updateData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
              
        UserDefaults.standard.set(displayName, forKey: "displayName_\(self.currentUID)")
            if let data = imageData {
                UserDefaults.standard.set(data, forKey: "profileImageData_\(self.currentUID)")}
                NotificationCenter.default.post(name: Notification.Name("ProfileUpdated"), object: nil)
                let alert = UIAlertController(title: "Success", message: "Profile successfully updated!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Alerts
    // Shows a simple UIAlertController with given title and message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePicker
/// Handles selection and cancellation of profile image picking
extension CustomiseProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
/// Handles return key behavior for text fields
extension CustomiseProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIImage Extension
extension UIImage {
 
    /// Resizes the image to fit within `maxSize` while maintaining aspect ratio
    func resized(toMax maxSize: CGFloat) -> UIImage? {
        let maxDimension = max(size.width, size.height)
        guard maxDimension > maxSize else { return self }

        let scale = maxSize / maxDimension
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    /// Converts image to JPEG Data with optional compression quality (0.0 - 1.0)
    func jpegDataCompressed(quality: CGFloat = 0.7) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
