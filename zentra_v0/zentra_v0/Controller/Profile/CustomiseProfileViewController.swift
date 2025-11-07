//
//  CustomiseProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 6/11/2025.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CustomiseProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    private let db = Firestore.firestore()
    private var currentUID: String { Auth.auth().currentUser?.uid ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        setupTextFields()
        loadUserProfile()
        makeProfileImageCircular()
    }

    // MARK: Load cached values first
    private func loadUserProfile() {
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
    
    private func makeProfileImageCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
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

    // MARK: Convert image to Base64, Save to Firestore,Update local cache, Notify ProfileViewController to reload
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
                    UserDefaults.standard.set(data, forKey: "profileImageData_\(self.currentUID)")
                }

            
                NotificationCenter.default.post(name: Notification.Name("ProfileUpdated"), object: nil)

   
                let alert = UIAlertController(title: "Success", message: "Profile successfully updated!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePicker
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
extension CustomiseProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIImage {
    // MARK: Resize the image to fit within maxSize while maintaining aspect ratio
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
    
    // MARK: Convert to JPEG Data with optional compression quality (0.0 - 1.0)
    func jpegDataCompressed(quality: CGFloat = 0.7) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
