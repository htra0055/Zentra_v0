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
//    private let placeFields: [GMSPlaceProperty] = [
//        .placeID, .name, .formattedAddress, .coordinate,
//        .types, .rating, .userRatingsTotal, .priceLevel, .photos
//    ]
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
//            contentStack.widthAnchor.constraint(equalTo: placesScrollView.widthAnchor)
//        ])
//    }
//
//    // MARK: - Fetch Places
//    private func fetchPlaces(for plan: Plan) {
//        // Clear previous results
//        contentStack.arrangedSubviews.forEach { view in
//            contentStack.removeArrangedSubview(view)
//            view.removeFromSuperview()
//        }
//
//        // Example location — replace with actual user location
//        let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
//        print("Fetching places for query: \(plan.activities.map { $0.query }.joined(separator: " "))")
//
//        FindPlaceEngine.shared.findPlaces(for: plan, location: userLocation, maxResults: 10) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let places):
//                    print("Fetched \(places.count) places")
//                    for place in places {
//                        if let name = place.name {
//                            print("Place: \(name), Rating: \(place.rating ?? 0)")
//                        }
//                        self?.displayPlaceCard(place)
//                    }
//                case .failure(let error):
//                    print("Error fetching places: \(error.localizedDescription)")
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//
//    private func loadPlacePhoto(for place: GMSPlace, completion: @escaping (UIImage?) -> Void) {
//        guard let photos = place.photos, let firstPhoto = photos.first else {
//            completion(nil)
//            return
//        }
//
//        GMSPlacesClient.shared().loadPlacePhoto(firstPhoto) { image, error in
//            if let error = error {
//                print("Error loading photo: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                completion(image)
//            }
//        }
//    }
//
//    // MARK: - Display Place Card
//    private func displayPlaceCard(_ place: GMSPlace) {
//        let container = UIView()
//        container.layer.cornerRadius = 12
//        container.backgroundColor = .secondarySystemBackground
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.heightAnchor.constraint(equalToConstant: 300).isActive = true
//
//        // Photo
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 12
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
//
//        // Labels
//        let nameLabel = UILabel()
//        nameLabel.font = .boldSystemFont(ofSize: 16)
//        nameLabel.text = place.name ?? "No name"
//        nameLabel.numberOfLines = 2
//
//        let addressLabel = UILabel()
//        addressLabel.font = .systemFont(ofSize: 14)
//        addressLabel.text = place.formattedAddress ?? "No address"
//        addressLabel.numberOfLines = 2
//        addressLabel.textColor = .secondaryLabel
//
//        let ratingLabel = UILabel()
//        ratingLabel.font = .systemFont(ofSize: 14)
//        ratingLabel.text = "Rating: N/A"
////        if let rating = place.rating {
////            ratingLabel.text = "Rating: \(rating) (\(place.userRatingsTotal ?? 0) reviews)"
////        } else {
////            ratingLabel.text = "Rating: N/A"
////        }
//
//        let priceLabel = UILabel()
//        priceLabel.font = .systemFont(ofSize: 14)
//        let priceText: String
//        switch place.priceLevel {
//        case .unknown:
//            priceText = "Price: N/A"
//        case .free:
//            priceText = "Price: Free"
//        case .cheap:
//            priceText = "Price: $"
//        case .medium:
//            priceText = "Price: $$"
//        case .high:
//            priceText = "Price: $$$"
//        case .expensive:
//            priceText = "Price: $$$$"
//        @unknown default:
//            priceText = "Price: N/A"
//        }
//        priceLabel.text = priceText
//
//        let typesLabel = UILabel()
//        typesLabel.font = .systemFont(ofSize: 14)
//        if let types = place.types, !types.isEmpty {
//            typesLabel.text = "Type: " + types.map { $0.capitalized }.joined(separator: ", ")
//        } else {
//            typesLabel.text = "Type: N/A"
//        }
//
//        // Stack for labels
//        let stack = UIStackView(arrangedSubviews: [nameLabel, addressLabel, ratingLabel, priceLabel, typesLabel])
//        stack.axis = .vertical
//        stack.spacing = 4
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        // Container stack
//        let containerStack = UIStackView(arrangedSubviews: [imageView, stack])
//        containerStack.axis = .vertical
//        containerStack.spacing = 8
//        containerStack.translatesAutoresizingMaskIntoConstraints = false
//
//        container.addSubview(containerStack)
//        NSLayoutConstraint.activate([
//            containerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
//            containerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
//            containerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
//            containerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
//        ])
//
//        contentStack.addArrangedSubview(container)
//
//        // Load photo
//        loadPlacePhoto(for: place) { image in
//            DispatchQueue.main.async {
//                imageView.image = image ?? UIImage(systemName: "photo")
//            }
//        }
//    }
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
