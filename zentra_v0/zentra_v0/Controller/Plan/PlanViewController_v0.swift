//
////  PlanViewController.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 17/9/2025.
//
//
//
//import UIKit
//import GooglePlaces
//import CoreLocation
//
//class PlanViewController: UIViewController {
//
//    // MARK: - Properties
//    var plan: Plan? {
//        didSet {
//            // If the view is loaded, fetch places immediately when plan is set
//            if isViewLoaded, let plan = plan {
//                print("Plan set via didSet: \(plan)")
//                fetchPlaces(for: plan)
//            }
//        }
//    }
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
//        // Fetch places if plan was already set before viewDidLoad
//        if let plan = plan {
//            print("Plan already set before viewDidLoad: \(plan)")
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
//    // MARK: - Fetch Places
//    private func fetchPlaces(for plan: Plan) {
//        // Clear previous results
//        contentStack.arrangedSubviews.forEach { view in
//            contentStack.removeArrangedSubview(view)
//            view.removeFromSuperview()
//        }
//
//        // Example location — replace with user location if available
//        let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
//        print("Fetching places for query: \(plan.activities.map { $0.query }.joined(separator: " "))")
//
//        FindPlaceEngine.shared.findPlaces(for: plan, location: userLocation, maxResults: 10) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let places):
//                    print("Fetched \(places.count) places")
//                    self?.displayPlaces(places)
//                case .failure(let error):
//                    print("Error fetching places: \(error.localizedDescription)")
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//
//    // MARK: - Display Places
//    private func displayPlaces(_ places: [GMSPlace]) {
//        if places.isEmpty {
//            let label = UILabel()
//            label.text = "No places found for this plan."
//            label.textColor = .secondaryLabel
//            label.textAlignment = .center
//            contentStack.addArrangedSubview(label)
//            return
//        }
//
//        for place in places {
//            let card = makePlaceCard(for: place)
//            contentStack.addArrangedSubview(card)
//        }
//    }
//
//    private func makePlaceCard(for place: GMSPlace) -> UIView {
//        let card = UIView()
//        card.backgroundColor = .secondarySystemBackground
//        card.layer.cornerRadius = 12
//        card.layer.shadowColor = UIColor.black.cgColor
//        card.layer.shadowOpacity = 0.1
//        card.layer.shadowOffset = CGSize(width: 0, height: 2)
//        card.layer.shadowRadius = 4
//        card.translatesAutoresizingMaskIntoConstraints = false
//
//        let nameLabel = UILabel()
//        nameLabel.font = .boldSystemFont(ofSize: 16)
//        nameLabel.text = place.name ?? "Unknown"
//        nameLabel.numberOfLines = 0
//
//        let typeLabel = UILabel()
//        typeLabel.font = .systemFont(ofSize: 14)
//        typeLabel.textColor = .secondaryLabel
//        typeLabel.text = place.types?.joined(separator: ", ") ?? "Unknown type"
//
//        let ratingLabel = UILabel()
//        ratingLabel.font = .systemFont(ofSize: 14)
//        ratingLabel.textColor = .systemYellow
//        ratingLabel.text = (place.rating ?? 0) > 0 ? "⭐️ \(place.rating)" : "No rating"
//
//        let stack = UIStackView(arrangedSubviews: [nameLabel, typeLabel, ratingLabel])
//        stack.axis = .vertical
//        stack.spacing = 4
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        card.addSubview(stack)
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
//            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
//            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
//        ])
//
//        return card
//    }
//
//    // MARK: - Error Handling
//    private func showError(_ error: Error) {
//        let alert = UIAlertController(title: "Error fetching places",
//                                      message: error.localizedDescription,
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//
//// MARK: v0
//
//
//// PlanViewController.swift
//// zentra_v0
//
////import UIKit
////import GooglePlaces
////
////class PlanViewController: UIViewController {
////
////    var plan: Plan?
////
////    @IBOutlet weak var placesScrollView: UIScrollView!
////    private let contentStack = UIStackView()
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        view.backgroundColor = .systemBackground
////
////        setupScrollView()
////
////        if let plan = plan {
////            fetchPlaces(for: plan)
////        }
////    }
////
////    private func setupScrollView() {
////        contentStack.axis = .vertical
////        contentStack.spacing = 16
////        contentStack.alignment = .fill
////        contentStack.translatesAutoresizingMaskIntoConstraints = false
////        placesScrollView.addSubview(contentStack)
////
////        NSLayoutConstraint.activate([
////            contentStack.topAnchor.constraint(equalTo: placesScrollView.topAnchor, constant: 16),
////            contentStack.leadingAnchor.constraint(equalTo: placesScrollView.leadingAnchor, constant: 16),
////            contentStack.trailingAnchor.constraint(equalTo: placesScrollView.trailingAnchor, constant: -16),
////            contentStack.bottomAnchor.constraint(equalTo: placesScrollView.bottomAnchor, constant: -16),
////            contentStack.widthAnchor.constraint(equalTo: placesScrollView.widthAnchor, constant: -32)
////        ])
////    }
////
////    private func fetchPlaces(for plan: Plan) {
////        // Example location — replace with user location
////        let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
////
////        FindPlaceEngine.shared.findPlaces(for: plan, location: userLocation, maxResults: 10) { [weak self] result in
////            DispatchQueue.main.async {
////                switch result {
////                case .success(let places):
////                    self?.displayPlaces(places)
////                case .failure(let error):
////                    self?.showError(error)
////                }
////            }
////        }
////    }
////
////    private func displayPlaces(_ places: [GMSPlace]) {
////        for place in places {
////            let card = makePlaceCard(for: place)
////            contentStack.addArrangedSubview(card)
////        }
////    }
////
////    private func makePlaceCard(for place: GMSPlace) -> UIView {
////        let card = UIView()
////        card.backgroundColor = .secondarySystemBackground
////        card.layer.cornerRadius = 12
////        card.layer.shadowColor = UIColor.black.cgColor
////        card.layer.shadowOpacity = 0.1
////        card.layer.shadowOffset = CGSize(width: 0, height: 2)
////        card.layer.shadowRadius = 4
////        card.translatesAutoresizingMaskIntoConstraints = false
////
////        let nameLabel = UILabel()
////        nameLabel.font = .boldSystemFont(ofSize: 16)
////        nameLabel.text = place.name ?? "Unknown"
////        nameLabel.numberOfLines = 0
////
////        let typeLabel = UILabel()
////        typeLabel.font = .systemFont(ofSize: 14)
////        typeLabel.textColor = .secondaryLabel
////        if let types = place.types {
////            typeLabel.text = types.joined(separator: ", ")
////        } else {
////            typeLabel.text = "Unknown type"
////        }
////
////        let ratingLabel = UILabel()
////        ratingLabel.font = .systemFont(ofSize: 14)
////        ratingLabel.textColor = .systemYellow
////        let rating = place.rating
////        ratingLabel.text = rating > 0 ? "⭐️ \(rating)" : "No rating"
////
////        let stack = UIStackView(arrangedSubviews: [nameLabel, typeLabel, ratingLabel])
////        stack.axis = .vertical
////        stack.spacing = 4
////        stack.translatesAutoresizingMaskIntoConstraints = false
////
////        card.addSubview(stack)
////        NSLayoutConstraint.activate([
////            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
////            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
////            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
////            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
////        ])
////
////        return card
////    }
////
////    private func showError(_ error: Error) {
////        let alert = UIAlertController(title: "Error fetching places",
////                                      message: error.localizedDescription,
////                                      preferredStyle: .alert)
////        alert.addAction(UIAlertAction(title: "OK", style: .default))
////        present(alert, animated: true)
////    }
////}
