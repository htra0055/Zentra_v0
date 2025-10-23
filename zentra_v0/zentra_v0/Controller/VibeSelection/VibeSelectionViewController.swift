//
//  VibeSelectionViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

// TODO: Need a button for reset -> clear the user selection (so they dont have to unselected all their option)
// TODO: Need to cofigure storyboard for collection view (UI Images)
// TODO: need to add notification, reminder, my activities (get more details, date added), maps: get navigation straight on explore map., working on fire database

import Foundation
import CoreLocation
import GooglePlaces
import UIKit


class VibeSelectionViewController: UIViewController {
    
    // MARK: - User input
    var selectedInterests: [Activity] = []
    var selectedEnergy: Mood?
    var selectedDuration: TripDuration?
    
    // TODO: Location: get from text input or nil
    // MARK: - Location Handling

    
    private let locationManager = CLLocationManager()
       
    // store the geocoded coordinate once resolved
    private var resolvedCoordinate: CLLocationCoordinate2D?
    private let userInputAddress: String? = "Melbourne"

    // Computed fallback order
    var searchLocation: CLLocationCoordinate2D {
        if let resolved = resolvedCoordinate {
            return resolved
        } else if let current = locationManager.location?.coordinate {
            return current
        } else {
            return CLLocationCoordinate2D(latitude: -37.8150309, longitude: 144.9663466)
        }
    }
    
    // Store original button styles
    private var originalButtonStyles: [UIButton: (bgColor: UIColor?, titleColor: UIColor?)] = [:]
    
    // MARK: - Outlets
    @IBOutlet weak var AdventureButton: UIButton!
    @IBOutlet weak var CulturalButton: UIButton!
    @IBOutlet weak var FoodieButton: UIButton!
    @IBOutlet weak var NightlifeButton: UIButton!
    @IBOutlet weak var RelaxationButton: UIButton!
    @IBOutlet weak var NatureButton: UIButton!
    
    @IBOutlet weak var LowkeyButton: UIButton!
    @IBOutlet weak var BalancedButton: UIButton!
    @IBOutlet weak var HighenergyButton: UIButton!
    
    @IBOutlet weak var DurationSegment: UISegmentedControl!
    @IBOutlet weak var YourSelectionStackView: UIStackView!
    @IBOutlet weak var CreatePlanButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save default styles for all buttons
        let allButtons = [
            AdventureButton, CulturalButton, FoodieButton, NightlifeButton,
            RelaxationButton, NatureButton,
            LowkeyButton, BalancedButton, HighenergyButton
        ]
        
        allButtons.forEach { button in
            if let button = button {
                originalButtonStyles[button] = (
                    bgColor: button.backgroundColor,
                    titleColor: button.titleColor(for: .normal)
                )
            }
        }
        

         // Location setup
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if let address = userInputAddress {
            getCoordinates(for: address) { [weak self] coordinate in guard let self = self else { return }
            self.resolvedCoordinate = coordinate
            print("Resolved user input to coordinate: \(String(describing: coordinate))")
                }
            }


        
        updateSelectionView()
    }
    
    // MARK: - Actions
    @IBAction func interestTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let type = Activity(rawValue: title) else { return }

        if selectedInterests.contains(type) {
            selectedInterests.removeAll { $0 == type }
            sender.restoreStyle(from: originalButtonStyles[sender])
        } else {
            selectedInterests.append(type)
            sender.selectStyle()
        }

        updateSelectionView()
    }

    @IBAction func energyTapped(_ sender: UIButton) {
        let buttons = [LowkeyButton, BalancedButton, HighenergyButton]
        buttons.forEach { $0?.restoreStyle(from: originalButtonStyles[$0!]) }
        
        sender.selectStyle()
        
        switch sender {
        case LowkeyButton: selectedEnergy = .Lowkey
        case BalancedButton: selectedEnergy = .Balanced
        case HighenergyButton: selectedEnergy = .HighEnergy
        default: break
        }
        
        updateSelectionView()
    }

    @IBAction func tripDurationChanged(_ sender: UISegmentedControl) {
        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex),
           let duration = TripDuration(rawValue: title) {
            selectedDuration = duration
        }
        updateSelectionView()
    }
    
    // convert string (location) to coordinates
    func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    // v1
    @IBAction func createPlanTapped(_ sender: UIButton) {
        guard let energy = selectedEnergy,
              let duration = selectedDuration else {
            showAlert(title: "Incomplete Selection", message: "Please complete all selections before creating a plan.")
            return
        }

        let plan = Plan(activities: selectedInterests, mood: energy, duration: duration, userCoordinate: resolvedCoordinate)

        // Handle both cases: resolved or not yet resolved
        if let address = userInputAddress, resolvedCoordinate == nil {
            showAlert(title: "Loading Location", message: "Please wait while we locate \"\(address)\".")
            getCoordinates(for: address) { [weak self] coordinate in
                guard let self = self else { return }
                self.resolvedCoordinate = coordinate
                self.runSearchEngine(with: plan)
            }
        } else {
            runSearchEngine(with: plan)
        }
    }

    
    // to resolve search location
    private func runSearchEngine(with plan: Plan) {
        let location = searchLocation
        print("Running search with coordinates: \(location.latitude), \(location.longitude)")

        FindPlaceEngine.shared.findPlaces(for: plan, userInputLocation: location) { result in
            switch result {
            case .success(let places):
                print("Found \(places.count) places")
                DispatchQueue.main.async {
                    self.showAlert(title: "Your Plan is saved and ready!", message: "") {
                        guard let tabBarController = self.tabBarController else { return }

                        // Case 1: Plan VC is inside navigation controller
                        if let navController = tabBarController.viewControllers?[1] as? UINavigationController,
                           let planVC = navController.viewControllers.first as? PlanViewController {
                            planVC.plan = plan
                        }
                        // Case 2: Plan VC is directly in tab bar
                        else if let planVC = tabBarController.viewControllers?[1] as? PlanViewController {
                            planVC.plan = plan
                        }

                        tabBarController.selectedIndex = 1
                    }
                }


                
                
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Could not find places: \(error.localizedDescription)")
                }
            }
        }
    }




    
    
    // MARK: - Helpers
    func updateSelectionView() {
        YourSelectionStackView.arrangedSubviews.forEach { view in
            YourSelectionStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        var parts: [String] = []
        if !selectedInterests.isEmpty {
            parts.append("Interests: " + selectedInterests.map { $0.rawValue }.joined(separator: ", "))
        }
        if let energy = selectedEnergy {
            parts.append("Energy: " + energy.rawValue)
        }
        if let duration = selectedDuration {
            parts.append("Duration: " + duration.rawValue)
        }
        
        if parts.isEmpty {
            let label = UILabel()
            label.text = "Your Selection: None"
            label.textColor = .secondaryLabel
            YourSelectionStackView.addArrangedSubview(label)
        } else {
            for part in parts {
                let label = UILabel()
                label.text = part
                label.textColor = .label
                YourSelectionStackView.addArrangedSubview(label)
            }
        }
    }
    
    // MARK: show notification
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIButton styling
extension UIButton {
    func selectStyle() {
        if let original = self.backgroundColor {
            self.backgroundColor = original.darker(by: 50)
        } else {
            self.backgroundColor = UIColor.systemGray2.darker(by: 50)
        }
        self.setTitleColor(.white, for: .normal)
    }
    
    func restoreStyle(from saved: (bgColor: UIColor?, titleColor: UIColor?)?) {
        self.backgroundColor = saved?.bgColor ?? .clear
        self.setTitleColor(saved?.titleColor ?? .systemBlue, for: .normal)
    }
}

// MARK: - UIColor helper
extension UIColor {
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: max(r - percentage/100, 0.0),
                           green: max(g - percentage/100, 0.0),
                           blue: max(b - percentage/100, 0.0),
                           alpha: a)
        }
        return self
    }
}

// Ask for permission
extension VibeSelectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updates to save battery
        manager.stopUpdatingLocation()
//        print("Current location updated: \(locations.last?.coordinate, default: <#default value#>)")
        
        if let coordinate = locations.last?.coordinate {
            print("Current location updated: \(coordinate)")
        } else {
            print("Current location updated: nil")
        }

    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Location access granted")
        }
    }
}
