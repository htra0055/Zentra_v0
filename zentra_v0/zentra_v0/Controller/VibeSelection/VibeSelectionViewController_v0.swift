////
////  VibeSelectionViewController_v0.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 8/10/2025.
////
//
//
//// TODO: Need a button for logout -> logout and go back to initial login, signup view
//// TODO: Need a button for reset -> clear the user selection (so they dont have to unselected all their option)
//// TODO: Need to cofigure storyboard for collection view (UI Images)
//
//
//import Foundation
//import CoreLocation
//import GooglePlaces
//import UIKit
//
//class VibeSelectionViewController: UIViewController {
//    
//    // MARK: - User input
//    var selectedInterests: [Activity] = []
//    var selectedEnergy: Mood?
//    var selectedDuration: TripDuration?
//    
//    // TODO: Location: get from text input or nil
////    private let locationManager = CLLocationManager()
////    let userInput: CLLocationCoordinate2D? = nil
////    let currentLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
////
////    var searchLocation: CLLocationCoordinate2D {
////        return userInput ?? locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
////    }
//
//
//
//
//
//    
//    // Store original button styles
//    private var originalButtonStyles: [UIButton: (bgColor: UIColor?, titleColor: UIColor?)] = [:]
//    
//    // MARK: - Outlets
//    @IBOutlet weak var AdventureButton: UIButton!
//    @IBOutlet weak var CulturalButton: UIButton!
//    @IBOutlet weak var FoodieButton: UIButton!
//    @IBOutlet weak var NightlifeButton: UIButton!
//    @IBOutlet weak var RelaxationButton: UIButton!
//    @IBOutlet weak var NatureButton: UIButton!
//    
//    @IBOutlet weak var LowkeyButton: UIButton!
//    @IBOutlet weak var BalancedButton: UIButton!
//    @IBOutlet weak var HighenergyButton: UIButton!
//    
//    @IBOutlet weak var DurationSegment: UISegmentedControl!
//    @IBOutlet weak var YourSelectionStackView: UIStackView!
//    @IBOutlet weak var CreatePlanButton: UIButton!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Save default styles for all buttons
//        let allButtons = [
//            AdventureButton, CulturalButton, FoodieButton, NightlifeButton,
//            RelaxationButton, NatureButton,
//            LowkeyButton, BalancedButton, HighenergyButton
//        ]
//        
//        allButtons.forEach { button in
//            if let button = button {
//                originalButtonStyles[button] = (
//                    bgColor: button.backgroundColor,
//                    titleColor: button.titleColor(for: .normal)
//                )
//            }
//        }
//        
//        // update user current location
////        locationManager.delegate = self
////        locationManager.desiredAccuracy = kCLLocationAccuracyBest
////        locationManager.requestWhenInUseAuthorization()
////        locationManager.startUpdatingLocation()
////
////
//        updateSelectionView()
//    }
//    
//    // MARK: - Actions
//    @IBAction func interestTapped(_ sender: UIButton) {
//        guard let title = sender.title(for: .normal),
//              let type = Activity(rawValue: title) else { return }
//
//        if selectedInterests.contains(type) {
//            selectedInterests.removeAll { $0 == type }
//            sender.restoreStyle(from: originalButtonStyles[sender])
//        } else {
//            selectedInterests.append(type)
//            sender.selectStyle()
//        }
//
//        updateSelectionView()
//    }
//
//    @IBAction func energyTapped(_ sender: UIButton) {
//        let buttons = [LowkeyButton, BalancedButton, HighenergyButton]
//        buttons.forEach { $0?.restoreStyle(from: originalButtonStyles[$0!]) }
//        
//        sender.selectStyle()
//        
//        switch sender {
//        case LowkeyButton: selectedEnergy = .Lowkey
//        case BalancedButton: selectedEnergy = .Balanced
//        case HighenergyButton: selectedEnergy = .HighEnergy
//        default: break
//        }
//        
//        updateSelectionView()
//    }
//
//    @IBAction func tripDurationChanged(_ sender: UISegmentedControl) {
//        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex),
//           let duration = TripDuration(rawValue: title) {
//            selectedDuration = duration
//        }
//        updateSelectionView()
//    }
//    
//    // v1
////    @IBAction func createPlanTapped(_ sender: UIButton) {
////        guard let energy = selectedEnergy,
////              let duration = selectedDuration else {
////            print("Please complete all selections")
////            return
////        }
////
////        let plan = Plan(activities: selectedInterests, mood: energy, duration: duration)
////
////        // Use searchLocation (user input or current location)
////        FindPlaceEngine.shared.findPlaces(for: plan, location: searchLocation) { result in
////            switch result {
////            case .success(let places):
////                print("Found \(places.count) places")
////
////                // Show notification to user on main thread
////                DispatchQueue.main.async {
////                    self.showAlert(title: "Your Plan is saved and ready!", message: "") {
////                        // Pass plan to PlanViewController in tab bar
////                        if let tabBarController = self.tabBarController {
////                            if let navController = tabBarController.viewControllers?[1] as? UINavigationController,
////                               let planVC = navController.viewControllers.first as? PlanViewController {
////                                planVC.plan = plan
////                            } else if let planVC = tabBarController.viewControllers?[1] as? PlanViewController {
////                                planVC.plan = plan
////                            }
////                            tabBarController.selectedIndex = 1
////                        }
////                    }
////                }
////
////            case .failure(let error):
////                print("Error: \(error)")
////                DispatchQueue.main.async {
////                    self.showAlert(title: "Error", message: "Could not find places: \(error.localizedDescription)")
////                }
////            }
////        }
////    }
//
//
//    // v0
//    @IBAction func createPlanTapped(_ sender: UIButton) {
//        guard let energy = selectedEnergy,
//              let duration = selectedDuration else {
//            print("Please complete all selections")
//            return
//        }
//        
//        let chosenActivities = selectedInterests
////        let plan = Plan(activities: chosenActivities, mood: energy, duration: duration)
//        
//        let plan = Plan(activities: selectedInterests, mood: selectedEnergy!, duration: selectedDuration!)
//        // Show notification to user
//        showAlert(title: "Your Plan is saved and ready!", message: "") {
//            // Pass plan to PlanViewController in tab bar
//            if let tabBarController = self.tabBarController {
//                if let navController = tabBarController.viewControllers?[1] as? UINavigationController,
//                   let planVC = navController.viewControllers.first as? PlanViewController {
//                    planVC.plan = plan
//                } else if let planVC = tabBarController.viewControllers?[1] as? PlanViewController {
//                    planVC.plan = plan
//                }
//                tabBarController.selectedIndex = 1
//            }
//        }
//    }
//    
//    // MARK: - Helpers
//    func updateSelectionView() {
//        YourSelectionStackView.arrangedSubviews.forEach { view in
//            YourSelectionStackView.removeArrangedSubview(view)
//            view.removeFromSuperview()
//        }
//        
//        var parts: [String] = []
//        if !selectedInterests.isEmpty {
//            parts.append("Interests: " + selectedInterests.map { $0.rawValue }.joined(separator: ", "))
//        }
//        if let energy = selectedEnergy {
//            parts.append("Energy: " + energy.rawValue)
//        }
//        if let duration = selectedDuration {
//            parts.append("Duration: " + duration.rawValue)
//        }
//        
//        if parts.isEmpty {
//            let label = UILabel()
//            label.text = "Your Selection: None"
//            label.textColor = .secondaryLabel
//            YourSelectionStackView.addArrangedSubview(label)
//        } else {
//            for part in parts {
//                let label = UILabel()
//                label.text = part
//                label.textColor = .label
//                YourSelectionStackView.addArrangedSubview(label)
//            }
//        }
//    }
//    
//    // MARK: show notification
//    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//            completion?()
//        })
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UIButton styling
//extension UIButton {
//    func selectStyle() {
//        if let original = self.backgroundColor {
//            self.backgroundColor = original.darker(by: 50)
//        } else {
//            self.backgroundColor = UIColor.systemGray2.darker(by: 50)
//        }
//        self.setTitleColor(.white, for: .normal)
//    }
//    
//    func restoreStyle(from saved: (bgColor: UIColor?, titleColor: UIColor?)?) {
//        self.backgroundColor = saved?.bgColor ?? .clear
//        self.setTitleColor(saved?.titleColor ?? .systemBlue, for: .normal)
//    }
//}
//
//// MARK: - UIColor helper
//extension UIColor {
//    func darker(by percentage: CGFloat = 30.0) -> UIColor {
//        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
//        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
//            return UIColor(red: max(r - percentage/100, 0.0),
//                           green: max(g - percentage/100, 0.0),
//                           blue: max(b - percentage/100, 0.0),
//                           alpha: a)
//        }
//        return self
//    }
//}
//
//// Ask for permission
//extension VibeSelectionViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        // Stop updates to save battery
//        manager.stopUpdatingLocation()
//        print("Current location updated: \(locations.last?.coordinate)")
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            print("Location access granted")
//        }
//    }
//}
