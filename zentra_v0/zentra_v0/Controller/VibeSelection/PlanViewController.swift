//
//  PlanViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//

import UIKit
import CoreLocation
import GooglePlaces
import GooglePlacesSwift

class PlanViewController: UIViewController {

    // MARK: - Properties
    var plan: Plan? {
        didSet {
            if isViewLoaded, let plan = plan {
                fetchPlaces(for: plan)
            }
        }
    }
    
    private var displayedPlaces: [GMSPlace] = []

    @IBOutlet weak var placesScrollView: UIScrollView!
    private let contentStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()

        if let plan = plan {
            fetchPlaces(for: plan)
        }
    }

    // MARK: - ScrollView Setup
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
    private func fetchPlaces(for plan: Plan) {
        contentStack.arrangedSubviews.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard let userLocation = plan.userCoordinate else {
            let alert = UIAlertController(title: "Missing Location",
                                          message: "Could not resolve location, using default (Melbourne).",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        FindPlaceEngine.shared.findPlaces(for: plan, userInputLocation: userLocation) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let places):
                if places.isEmpty {
                    let alert = UIAlertController(title: "No Results",
                                                  message: "No nearby places found for your plan.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.displayPlaces(places)
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Search Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Display Places
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

    // MARK: - Place Tapped
    @objc private func placeTapped(_ sender: UITapGestureRecognizer) {
        guard let container = sender.view else { return }
        let index = container.tag
        guard index < displayedPlaces.count else { return }
        let place = displayedPlaces[index]

        let alert = UIAlertController(title: place.name, message: "Choose an action", preferredStyle: .alert)

        // Open Google Search
        alert.addAction(UIAlertAction(title: "Search Details", style: .default, handler: { _ in
            if let name = place.name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.google.com/search?q=\(name)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))

        // Add to My Activities
        alert.addAction(UIAlertAction(title: "Add to My Activities", style: .default, handler: { _ in
            self.addPlaceToActivities(place)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Add to Activities
    private func addPlaceToActivities(_ place: GMSPlace) {
        let userLists = ActivityManager.shared.getUserLists()
        let alert = UIAlertController(title: "Select a list", message: nil, preferredStyle: .alert)

        // Existing lists
        for list in userLists {
            alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
                ActivityManager.shared.addActivity(place: place, toList: list) { error in
                    if let error = error { self.showError(error) }
                    else { print("Activity added to \(list.name)") }
                }
            }))
        }

        // Create new list
        alert.addAction(UIAlertAction(title: "Create New List", style: .default, handler: { _ in
            self.createNewListAndAdd(place: place)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func createNewListAndAdd(place: GMSPlace) {
        let alert = UIAlertController(title: "New List", message: "Enter a name for your new list", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "List Name" }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let listName = alert.textFields?.first?.text, !listName.isEmpty else { return }

            ActivityManager.shared.createList(name: listName) { error in
                if let error = error { self.showError(error); return }

                guard let newList = ActivityManager.shared.getUserLists().last else { return }
                ActivityManager.shared.addActivity(place: place, toList: newList) { error in
                    if let error = error { self.showError(error) }
                    else { print("Activity added to new list \(listName)") }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Error
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
