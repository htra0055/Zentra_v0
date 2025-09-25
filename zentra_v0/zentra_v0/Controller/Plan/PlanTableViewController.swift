//
//  PlanTableViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 24/9/2025.
//


import UIKit
import GooglePlaces
import GooglePlacesSwift
import SwiftUI
import CoreLocation

class PlanTableViewController: UITableViewController {

    let CELL_PLACE = "placeCell"

    var plan: Plan?
    var places: [GMSPlace] = [] // Fetched places

    // Keep hosting controllers per indexPath
    var hostingControllers: [IndexPath: UIHostingController<PlaceDetailsCompactView>] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_PLACE)

        loadPlaces()
    }

    // MARK: - Load Places
    func loadPlaces() {
        guard let plan = plan else { return }

        // Example: replace with actual user location
        let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        FindPlaceEngine.shared.findPlaces(for: plan, location: userLocation, maxResults: 10) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let foundPlaces):
                    self?.places = foundPlaces
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching places: \(error)")
                }
            }
        }
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PLACE, for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let place = places[indexPath.row]

        // If placeID is missing, skip
        guard let placeID = place.placeID else {
            cell.textLabel?.text = place.name ?? "Unknown place"
            return cell
        }

        // Reuse hosting controller if exists
        if let hostingController = hostingControllers[indexPath] {
            cell.contentView.addSubview(hostingController.view)
        } else {
            let content: Set<PlaceDetailsCompactContent> = [.media(), .address(), .rating(), .type()]
            let theme = PlacesMaterialTheme()
            let configuration = PlaceDetailsCompactConfiguration(content: content, theme: theme)

            let placeDetailsCallback: (PlaceDetailsResult) -> Void = { result in
                if let place = result.place {
                    print("Loaded place: \(place.description)")
                } else {
                    print("Error: \(String(describing: result.error))")
                }
            }

            let hostingController = UIHostingController(
                rootView: PlaceDetailsCompactView(
                    orientation: .vertical,
                    query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                    configuration: configuration,
                    placeDetailsCallback: placeDetailsCallback
                )
            )

            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(hostingController.view)
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            hostingController.didMove(toParent: self)
            hostingControllers[indexPath] = hostingController
        }

        return cell
    }
}
