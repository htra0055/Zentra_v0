//
//  AboutMeViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/11/2025.
//  About Page — Software License & Acknowledgements
//

import UIKit

class AboutMeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About Zentra"
        setupTextView()
        loadStyledAboutContent()
    }
    
    // MARK: - Setup
    private func setupTextView() {
        aboutMeTextView.isEditable = false
        aboutMeTextView.layer.cornerRadius = 12
        aboutMeTextView.layer.borderWidth = 1
        aboutMeTextView.layer.borderColor = UIColor.systemGray4.cgColor
        aboutMeTextView.textColor = .label
        aboutMeTextView.backgroundColor = UIColor.systemBackground
    }
    
    // MARK: - Content
    private func loadStyledAboutContent() {
        let fullText = NSMutableAttributedString()
        
        func addSection(title: String, body: String) {
            let titleAttr = NSAttributedString(
                string: "\n\(title)\n",
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ]
            )
            let bodyAttr = NSAttributedString(
                string: body + "\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            fullText.append(titleAttr)
            fullText.append(bodyAttr)
        }
        
        

        addSection(
            title: "About Zentra",
            body: """

            Zentra is a mindfulness and wellness application designed to help users stay centred and connected in their daily routines. 
            
            Developed as part of an academic project, the app integrates modern iOS frameworks, cloud-based features, and ethical design principles.
            
            
            """
        )
        
 
        addSection(
            title: "Software License Agreement",
            body: """
            
            This application and its source code are protected under copyright law.

            Redistribution, modification, or commercial use without permission is strictly prohibited.

            Third-party libraries and APIs integrated within Zentra are used under their respective licenses, which must be followed when using or distributing these components. 

            Users are granted a non-commercial, limited, personal license to install and use Zentra for demonstration, learning, or personal purposes only.

            The developer makes no warranties regarding the software and is not responsible for any direct or indirect consequences resulting from its use.
            
            
            """
        )
        

        addSection(
            title: "Frameworks & Libraries",
            body: """
            
            - UIKit (Apple)
            - Firebase Authentication & Firestore (Google)
            - Google Places API (Google)
            - CoreLocation (Apple)
            - Swift Concurrency (Apple)
            - UserNotifications (Apple)
            
            All frameworks are used in compliance with their respective software licenses.
            
            
            """
        )
        

        addSection(
            title: "Tutorials & Learning Resources",
            body: """
            
            - Apple Developer Documentation: https://developer.apple.com/documentation/
            - Firebase iOS Setup Guide: https://firebase.google.com/docs/ios/setup
            - Google Places iOS SDK: https://developers.google.com/maps/documentation/places/ios-sdk
            - ChatGPT (OpenAI) — used for debugging and UI code review.
            - WWDC24: SwiftUI Essentials (Apple Developer): https://youtu.be/HyQgpxX__-A?si=gSBOCC_-MPD3JsQY
            - CodeWithChris — “How to Make an App in 8 Days”: https://www.youtube.com/watch?v=uvLUJev1F20
            
            
            """
        )
        
   
        addSection(
            title: "Assets & Icons",
            body: """
            
            - SF Symbols (Apple)
            - App icons and UI assets created in accordance with Apple’s Human Interface Guidelines.
            
            
            """
        )
        

        addSection(
            title: "Academic Integrity & Attribution Statement",
            body: """
            
            All external tutorials, libraries, and tools (including AI assistance) have been properly acknowledged. 
            Inline code comments identify portions of code influenced by tutorials or external references.
            No copyrighted or proprietary assets were used without permission.
            
            
            """
        )
        
    

        let quoteText = NSMutableAttributedString()

        // Quote
        let quote = NSAttributedString(
            string: "“Be present. Stay connected. Live centred.”\n",
            attributes: [
                .font: UIFont.italicSystemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
        )
        quoteText.append(quote)

  
        let copyright = NSAttributedString(
            string: "© 2025 Evelyn Tran. All rights reserved.",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        quoteText.append(copyright)


        fullText.append(quoteText)

        
        aboutMeTextView.attributedText = fullText
    }
}
