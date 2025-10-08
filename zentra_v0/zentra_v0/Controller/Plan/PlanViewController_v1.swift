////
////  PlanViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 17/9/2025.
////
//
//import UIKit
//import CoreLocation
//import GooglePlaces
//import GooglePlacesSwift
//import SwiftUI
//
//class PlanViewController: UIViewController {
//
//    // MARK: - Properties
//    var plan: Plan? {
//        didSet {
//            if isViewLoaded, let plan = plan {
//                fetchPlaces(for: plan)
//            }
//        }
//    }
//    
//    private var displayedPlaces: [GMSPlace] = [] // keep track of the displayed places
//
//    @IBOutlet weak var placesScrollView: UIScrollView!
//    private let contentStack = UIStackView()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupScrollView()
//
//        if let plan = plan {
//            fetchPlaces(for: plan)
//        }
//    }
//
//    // MARK: - ScrollView Setup
//    private func setupScrollView() {
//        contentStack.axis = .vertical
//        contentStack.spacing = 16
//        contentStack.alignment = .fill
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//        placesScrollView.addSubview(contentStack)
//
//        NSLayoutConstraint.activate([
//            contentStack.topAnchor.constraint(equalTo: placesScrollView.topAnchor, constant: 16),
//            contentStack.leadingAnchor.constraint(equalTo: placesScrollView.leadingAnchor, constant: 16),
//            contentStack.trailingAnchor.constraint(equalTo: placesScrollView.trailingAnchor, constant: -16),
//            contentStack.bottomAnchor.constraint(equalTo: placesScrollView.bottomAnchor, constant: -16),
//            contentStack.widthAnchor.constraint(equalTo: placesScrollView.widthAnchor, constant: -32)
//        ])
//    }
//
//    // MARK: - vo Fetch Places
//    
//    
//        //MARK: V1
//    private func fetchPlaces(for plan: Plan) {
//        // Clear previous results
//        contentStack.arrangedSubviews.forEach { view in
//            contentStack.removeArrangedSubview(view)
//            view.removeFromSuperview()
//        }
//
//        let userLocation = CLLocationCoordinate2D(latitude: -37.8150309, longitude: 144.9663466)
//
//        for activity in plan.activities {
//            let textQuery = activity.query
//
//            // Prepare request
//            let fields: [GMSPlaceProperty] = [.placeID, .name, .coordinate, .photos, .rating, .formattedAddress, .openingHours]
//            let request = GMSPlaceSearchByTextRequest(textQuery: textQuery, placeProperties: fields.map { $0.rawValue })
//            request.locationBias = GMSPlaceCircularLocationOption(userLocation, 5000) // 5 km radius
//            request.maxResultCount = 10
//            request.isOpenNow = true
//
//            GMSPlacesClient.shared().searchByText(with: request) { [weak self] results, error in
//                guard let self else { return }
//                if let error = error {
//                    print("Text search error: \(error.localizedDescription)")
//                    return
//                }
//                guard let places = results as? [GMSPlace] else { return }
//                self.displayPlaces(places)
//            }
//        }
//    }
//
//
//
//   
//    private func fetchPlacePhoto(for place: GMSPlace, completion: @escaping (UIImage?) -> Void) {
//        guard let photoMetadata = place.photos?.first else {
//            completion(nil)
//            return
//        }
//
//        let fetchRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: CGSize(width: 800, height: 800))
//        GMSPlacesClient.shared().fetchPhoto(with: fetchRequest) { image, error in
//            if let error = error {
//                print("Photo fetch error: \(error.localizedDescription)")
//            }
//            completion(image)
//        }
//    }
//
//    
//    // MARK: - Display Places
//    // v0
////    private func displayPlaces(_ places: [GMSPlace]) {
////        for place in places {
////            let container = UIView()
////            container.layer.cornerRadius = 12
////            container.backgroundColor = .secondarySystemBackground
////            container.translatesAutoresizingMaskIntoConstraints = false
////            container.heightAnchor.constraint(equalToConstant: 250).isActive = true
////
////            let label = UILabel()
////            label.numberOfLines = 2
////            label.text = place.name
////            label.font = .boldSystemFont(ofSize: 16)
////
////            container.addSubview(label)
////            label.translatesAutoresizingMaskIntoConstraints = false
////            NSLayoutConstraint.activate([
////                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
////                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
////                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
////            ])
////
////            // Fetch photo
////            fetchPlacePhoto(for: place) { image in
////                if let image = image {
////                    let imageView = UIImageView(image: image)
////                    imageView.contentMode = .scaleAspectFill
////                    imageView.clipsToBounds = true
////                    container.addSubview(imageView)
////                    imageView.translatesAutoresizingMaskIntoConstraints = false
////                    NSLayoutConstraint.activate([
////                        imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
////                        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
////                        imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
////                        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
////                    ])
////                }
////            }
////
////            contentStack.addArrangedSubview(container)
////        }
////    }
//
//
//
//
//    // v1
//    private func displayPlaces(_ places: [GMSPlace]) {
//        self.displayedPlaces = places // <- store them here
//        for (index, place) in places.enumerated() {
//            let container = UIView()
//            container.layer.cornerRadius = 12
//            container.backgroundColor = .secondarySystemBackground
//            container.translatesAutoresizingMaskIntoConstraints = false
//            container.heightAnchor.constraint(equalToConstant: 250).isActive = true
//
//            let label = UILabel()
//            label.numberOfLines = 2
//            label.text = place.name
//            label.font = .boldSystemFont(ofSize: 16)
//            container.addSubview(label)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
//                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
//                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
//            ])
//
//            fetchPlacePhoto(for: place) { image in
//                if let image = image {
//                    let imageView = UIImageView(image: image)
//                    imageView.contentMode = .scaleAspectFill
//                    imageView.clipsToBounds = true
//                    container.addSubview(imageView)
//                    imageView.translatesAutoresizingMaskIntoConstraints = false
//                    NSLayoutConstraint.activate([
//                        imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
//                        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                        imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//                        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//                    ])
//                }
//            }
//
//            // Make tappable
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeTapped(_:)))
//            container.addGestureRecognizer(tapGesture)
//            container.isUserInteractionEnabled = true
//            container.tag = index
//
//            contentStack.addArrangedSubview(container)
//        }
//    }
//
////    @objc private func placeTapped(_ sender: UITapGestureRecognizer) {
////        guard let container = sender.view else { return }
////        let index = container.tag
////        guard index < displayedPlaces.count else { return }
////        let place = displayedPlaces[index]
////
////        if let name = place.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
////           let url = URL(string: "https://www.google.com/search?q=\(name)") {
////            UIApplication.shared.open(url, options: [:], completionHandler: nil)
////        }
////    }
//    
//    // v1
//    @objc private func placeTapped(_ sender: UITapGestureRecognizer) {
//        guard let container = sender.view else { return }
//        let index = container.tag
//        guard index < displayedPlaces.count else { return }
//        let place = displayedPlaces[index]
//
//        let alert = UIAlertController(title: place.name, message: "Choose an action", preferredStyle: .alert)
//
//        // Option 1: Search Details
//        alert.addAction(UIAlertAction(title: "Search Details", style: .default, handler: { _ in
//            if let name = place.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//               let url = URL(string: "https://www.google.com/search?q=\(name)") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        }))
//
//        // Option 2: Add to My Activities
//        alert.addAction(UIAlertAction(title: "Add to My Activities", style: .default, handler: { _ in
//            self.showAddToActivities(for: place)
//        }))
//
//        // Cancel
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        present(alert, animated: true)
//    }
//
//    private func showAddToActivities(for place: GMSPlace) {
//        // Example: Fetch user’s existing lists
//        let userLists = ActivityManager.shared.getUserLists() // returns [ActivityList]
//
//        let alert = UIAlertController(title: "Select a list", message: nil, preferredStyle: .alert)
//        
//        // Existing lists
//        for list in userLists {
//            alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
//                ActivityManager.shared.addActivity(place: place, toList: list)
//            }))
//        }
//
//        // Option to create new list
//        alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
//            self.createNewListAndAdd(place: place)
//        }))
//
//        // Cancel
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        present(alert, animated: true)
//    }
//    
//    private func createNewListAndAdd(place: GMSPlace) {
//        
//        
//        let alert = UIAlertController(title: "New List", message: "Enter a name for your new list", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "List Name"
//        }
//
//        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
//            guard let listName = alert.textFields?.first?.text, !listName.isEmpty else { return }
//            let newList = ActivityManager.shared.createList(name: listName)
//            ActivityManager.shared.addActivity(place: place, toList: newList)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        present(alert, animated: true)
//    }
//
//
//    // MARK: - Error Handling
//    private func showError(_ error: Error) {
//        let alert = UIAlertController(
//            title: "Error fetching places",
//            message: error.localizedDescription,
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
