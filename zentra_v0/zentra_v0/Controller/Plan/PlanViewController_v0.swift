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
//        let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
//
//        for activity in plan.activities {
//            let textQuery = activity.query
//
//            // Prepare request
//            let fields: [GMSPlaceProperty] = [.placeID, .name, .coordinate, .photos, .rating, .formattedAddress, .openingHours]
//            let request = GMSPlaceSearchByTextRequest(textQuery: textQuery, placeProperties: fields.map { $0.rawValue })
//            request.locationBias = GMSPlaceCircularLocationOption(userLocation, 5000) // 5 km radius
//            request.maxResultCount = 5
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
//    @objc private func placeTapped(_ sender: UITapGestureRecognizer) {
//        guard let container = sender.view else { return }
//        let index = container.tag
//        guard index < displayedPlaces.count else { return }
//        let place = displayedPlaces[index]
//
//        if let name = place.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//           let url = URL(string: "https://www.google.com/search?q=\(name)") {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }
//
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
