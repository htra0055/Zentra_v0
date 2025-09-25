//
//  AppDelegate.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import UIKit

import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    var databaseController: FirebaseController?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // FirebaseApp.configure()
        databaseController = FirebaseController()
        
        // Google API
        GMSPlacesClient.provideAPIKey("AIzaSyCo1nn7NPqkq75PSuilJCiWZo-5foDRtCk")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
   
    }


}

