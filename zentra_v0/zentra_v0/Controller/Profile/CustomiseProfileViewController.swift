//
//  CustomiseProfileViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 6/11/2025.
//


import UIKit

class CustomiseProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load existing info
        nameTextField.text = UserDefaults.standard.string(forKey: "userName")
        emailTextField.text = UserDefaults.standard.string(forKey: "userEmail")
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = UIImage(systemName: "person.and.background.dotted")
        }
        
        // Make profile image round & tappable
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @objc func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func saveChangesButton(_ sender: Any) {
        guard let newName = nameTextField.text, !newName.isEmpty,
              let newEmail = emailTextField.text, !newEmail.isEmpty else {
            print("Name or email is empty")
            return
        }
        
        // Save info
        UserDefaults.standard.set(newName, forKey: "userName")
        UserDefaults.standard.set(newEmail, forKey: "userEmail")
        
        if let image = profileImageView.image, let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Image Picker Delegate
extension CustomiseProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
