//
//  DirectionsViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 22/10/2025.
//
// Acknowledgements:
//
// Libraries:
// - Firebase Firestore (Apache 2.0 License) – https://firebase.google.com/docs/firestore
// - Firebase Auth (Apache 2.0 License) – https://firebase.google.com/docs/auth
// - Google Places SDK (Google) – https://developers.google.com/places/ios-sdk
//
//External Resources / Tutorials:
//- StackOverflow – various Swift Firestore examples (https://stackoverflow.com/questions/70864512/get-all-collections-that-are-declared-on-document-swift-firestore-firebase)
//- YouTube tutorial on GMSPlace integration (https://www.youtube.com/watch?v=Jj7f5W2W1h0)


import UIKit
import MapKit
import CoreLocation

class DirectionsViewController: UIViewController {

    var destination: MKMapItem! 

    private let mapView = MKMapView()
    private let controlBar = UIView()
    private let modeControl = UISegmentedControl(items: ["Drive", "Walk", "Transit"])
    private let etaLabel = UILabel()
    private let startButton = UIButton(type: .system)

    private var currentRoute: MKRoute?
    private let locationManager = CLLocationManager()
    private var hasCenteredOnUser = false
    private var isNavigating = false

    // MARK: - Lifecycle
    /// Sets up the view, map, control bar, and location manager when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = destination?.name ?? "Directions"
        view.backgroundColor = .systemBackground

        setupMapView()
        setupControlBar()
        setupLocationManager()
    }

    // MARK: - Setup
    /// Configures the MKMapView, sets delegate, shows user location, and enables tracking.
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
    }

    /// Configures the bottom control bar with transport mode selector, ETA label, and start navigation button.
    private func setupControlBar() {
        controlBar.translatesAutoresizingMaskIntoConstraints = false
        controlBar.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        controlBar.layer.cornerRadius = 16
        controlBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        controlBar.layer.shadowOpacity = 0.15
        controlBar.layer.shadowRadius = 4
        controlBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.addSubview(controlBar)

        modeControl.selectedSegmentIndex = 0
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        etaLabel.font = .systemFont(ofSize: 14, weight: .medium)
        etaLabel.textAlignment = .center
        etaLabel.textColor = .secondaryLabel
        etaLabel.text = "Waiting for location..."

        startButton.setTitle("Start Navigation", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        startButton.backgroundColor = .systemBlue
        startButton.tintColor = .white
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [modeControl, etaLabel, startButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        controlBar.addSubview(stack)

        NSLayoutConstraint.activate([
            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: controlBar.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: controlBar.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: controlBar.bottomAnchor, constant: -12),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    /// Configures CLLocationManager, requests user location permission, and starts updating location.
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    
    // MARK: - Routing, Adjust view, Update ETA, Add destination marker
    /// Calculates a route from the user's current location to the destination using the specified transport mode.
    /// Updates the map with route overlay, centers the map, updates ETA label, and adds destination annotation.
    /// - Parameter mode: The transport type (drive, walk, or transit).
    private func calculateRoute(mode: MKDirectionsTransportType) {
        guard let userLocation = mapView.userLocation.location else {
            etaLabel.text = "Waiting for location..."
            return
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = destination
        request.transportType = mode

        etaLabel.text = "Calculating route..."

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error updating ETA: \(error.localizedDescription)")
                self.etaLabel.text = "No route found"
                return
            }

            guard let route = response?.routes.first else {
                self.etaLabel.text = "No route found"
                return
            }

            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline)

       
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 80, left: 30, bottom: 200, right: 30),
                animated: true
            )

            
            let travelTime = Int(route.expectedTravelTime / 60)
            let distance = String(format: "%.1f km", route.distance / 1000)
            self.etaLabel.text = "ETA: \(travelTime) min • \(distance)"

            
            let destAnnotation = MKPointAnnotation()
            destAnnotation.title = self.destination.name
            destAnnotation.coordinate = self.destination.placemark.coordinate
            self.mapView.showAnnotations([self.mapView.userLocation, destAnnotation], animated: true)
        }
    }

    // MARK: - Actions
    /// Triggered when the transport mode segmented control is changed. Recalculates the route accordingly.
    @objc private func modeChanged() {
        calculateRoute(mode: currentTransportType())
    }

    /// Starts navigation along the current route. Centers map on user and updates UI accordingly.
    @objc private func startNavigation() {
        guard let route = currentRoute else {
            let alert = UIAlertController(title: "Route Not Ready", message: "Please wait until your location and route are loaded.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        isNavigating = true
        mapView.userTrackingMode = .followWithHeading

        mapView.setVisibleMapRect(
            route.polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 140, right: 20),
            animated: true
        )

        etaLabel.text = "Navigating..."
    }


    /// Returns the currently selected transport type based on the segmented control.
    private func currentTransportType() -> MKDirectionsTransportType {
        switch modeControl.selectedSegmentIndex {
        case 1: return .walking
        case 2: return .transit
        default: return .automobile
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension DirectionsViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    /// Called when location authorization status changes. Starts location updates if authorized, otherwise updates ETA label.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else if manager.authorizationStatus == .denied {
            etaLabel.text = "Location access denied"
        }
    }

    /// Called when new location updates are received. Updates ETA label, centers map on first update, and tracks user while navigating.
    /// - Parameter locations: Array of CLLocation objects from the location manager.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        etaLabel.text = "User location: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))"

        if !hasCenteredOnUser {
            hasCenteredOnUser = true
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)

            calculateRoute(mode: currentTransportType())
        }

        if isNavigating {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }

}

// MARK: - MKMapViewDelegate
extension DirectionsViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    /**
    Returns a renderer for a map overlay. Configures polyline appearance for routes.
    - Parameter overlay: The overlay to render.
    - Returns: MKOverlayRenderer configured for the overlay.
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 6
        return renderer
    }
}
