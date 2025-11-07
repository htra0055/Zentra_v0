//
//  PlanViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - Google Places SDK for iOS (Google) – https://developers.google.com/places/ios-sdk
// - Google Places Swift SDK (Google) – https://developers.google.com/places/ios-sdk/swift
// - CoreLocation (Apple) – https://developer.apple.com/documentation/corelocation
//
// Purpose:
// Displays a user's plan and associated nearby places.
// Supports fetching places from Google Places, showing photos, and adding selected places
// to user's activity lists. Includes error handling for missing locations or failed queries.
//


import UIKit
import CoreLocation
import GooglePlaces
import GooglePlacesSwift

/// `PlanViewController` displays the places associated with a given `Plan` object.
/// Users can view place details, search on Google, or add them to their activity lists.
class PlanViewController: UIViewController {

    // MARK: - Properties
    
    /// The current plan to display
    var plan: Plan? {
        didSet {
            if isViewLoaded, let plan = plan {
                fetchPlaces(for: plan)
            }
        }
    }

    /// Places currently displayed in the scroll view
    private var displayedPlaces: [GMSPlace] = []

    /// ScrollView container for dynamically added place views
    @IBOutlet weak var placesScrollView: UIScrollView!
    
    /// StackView inside scrollView to hold place views
    private let contentStack = UIStackView()

    
    // MARK: - Lifecycle
    /**
     Configures the view and sets up the scroll view.
     If a `plan` is already set, fetches nearby places.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()

        if let plan = plan {
            fetchPlaces(for: plan)
        }
    }

    // MARK: - ScrollView Setup
    /**
    Sets up the stack view inside the scroll view with proper constraints
    for vertical scrolling and spacing between place containers.
    */
    private func setupScrollView() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        placesScrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: placesScrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: placesScrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: placesScrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: placesScrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: placesScrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Fetch Places
    /**
     Fetches places relevant to the given plan using `FindPlaceEngine`.
     - Parameter plan: The plan object containing location and preferences.
     If the user location is missing, an alert is shown and a default location may be used.
     On success, calls `displayPlaces(_:)`. On failure or no results, shows an alert.
     */
    private func fetchPlaces(for plan: Plan) {
        // Clear previous views
        contentStack.arrangedSubviews.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard let userLocation = plan.userCoordinate else {
            let alert = UIAlertController(
                title: "Missing Location",
                message: "Could not resolve location, using default (Melbourne).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        FindPlaceEngine.shared.findPlaces(for: plan, userInputLocation: userLocation) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let places):
                if places.isEmpty {
                    let alert = UIAlertController(
                        title: "No Results",
                        message: "No nearby places found for your plan.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.displayPlaces(places)
                }
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Search Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Display Places
      /**
       Dynamically adds place views to the scroll view stack.
       - Parameter places: Array of `GMSPlace` to display.
       Each view includes the place name, optional photo, and tap gesture to handle user actions.
       */
    private func displayPlaces(_ places: [GMSPlace]) {
        self.displayedPlaces = places

        for (index, place) in places.enumerated() {
            let container = UIView()
            container.layer.cornerRadius = 12
            container.backgroundColor = .secondarySystemBackground
            container.translatesAutoresizingMaskIntoConstraints = false
            container.heightAnchor.constraint(equalToConstant: 250).isActive = true

            let label = UILabel()
            label.numberOfLines = 2
            label.text = place.name
            label.font = .boldSystemFont(ofSize: 16)
            container.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
            ])

            fetchPlacePhoto(for: place) { image in
                if let image = image {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    container.addSubview(imageView)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
                        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                        imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
                    ])
                }
            }

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeTapped(_:)))
            container.addGestureRecognizer(tapGesture)
            container.isUserInteractionEnabled = true
            container.tag = index

            contentStack.addArrangedSubview(container)
        }
    }

    private func fetchPlacePhoto(for place: GMSPlace, completion: @escaping (UIImage?) -> Void) {
        guard let photoMetadata = place.photos?.first else { completion(nil); return }
        let request = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: CGSize(width: 800, height: 800))
        GMSPlacesClient.shared().fetchPhoto(with: request) { image, error in
            if let error = error { print("Photo fetch error: \(error.localizedDescription)") }
            completion(image)
        }
    }

    // MARK: - Place Actions
    /**
     Handles tap on a place container, allowing the user to:
     - Search place details via Google search
     - Add the place to an existing or new activity list
     */
    @objc private func placeTapped(_ sender: UITapGestureRecognizer) {
        guard let container = sender.view else { return }
        let index = container.tag
        guard index < displayedPlaces.count else { return }
        let place = displayedPlaces[index]

        let alert = UIAlertController(title: place.name, message: "Choose an action", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Search Details", style: .default, handler: { _ in
            if let name = place.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.google.com/search?q=\(name)") {
                UIApplication.shared.open(url, options: [:])
            }
        }))

        alert.addAction(UIAlertAction(title: "Add to My Activities", style: .default, handler: { _ in
            self.addPlaceToActivities(place)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    // MARK: - Add Place to Activities
       /**
        Presents UI to add a `GMSPlace` to an existing list or create a new list.
        - Parameter place: The place to add.
        */
    private func addPlaceToActivities(_ place: GMSPlace) {
        ActivityManager.shared.fetchUserListsForCurrentUser { lists in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Select a list", message: nil, preferredStyle: .alert)

                for list in lists {
                    alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
                        self.addPlace(place, to: list)
                    }))
                }

                alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
                    self.createNewListAndAdd(place: place)
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }


    /**
     Adds a `GMSPlace` to a specific `ActivityList`.
     - Parameters:
        - place: The place to add.
        - list: The activity list to which the place will be added.
     */
    private func addPlace(_ place: GMSPlace, to list: ActivityList) {
        ActivityManager.shared.addActivity(place: place, toList: list) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showError(error)
                } else {
                    let confirmation = UIAlertController(
                        title: "Saved!",
                        message: "\(place.name ?? "Place") has been saved to \"\(list.name)\".",
                        preferredStyle: .alert
                    )
                    confirmation.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(confirmation, animated: true)
                }
            }
        }
    }


    /**
     Creates a new activity list and adds the specified place to it.
     - Parameter place: The place to add to the newly created list.
     */
    private func createNewListAndAdd(place: GMSPlace) {
        let alert = UIAlertController(title: "New List", message: "Enter a name for your new list", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "List Name" }

        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let listName = alert.textFields?.first?.text, !listName.isEmpty else { return }

            ActivityManager.shared.createList(name: listName) { error in
                if let error = error {
                    self.showError(error)
                    return
                }

                ActivityManager.shared.fetchUserLists { fetchedLists in
                    guard let newList = fetchedLists.first(where: { $0.name == listName }) else { return }
                    self.addPlace(place, to: newList)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Error Handling
      /**
       Displays an alert for a given error.
       - Parameter error: The error to display.
       */
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

