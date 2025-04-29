import Foundation
import MapKit
import CoreLocation
import Network

// Manages location services and nearby hospital search functionality
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var lastLocationUpdate: Date?
    private let locationUpdateInterval: TimeInterval = 300 // 5 minutes
    private let networkMonitor = NWPathMonitor()
    
    // Published properties for view updates
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var hospitals: [HospitalLocation] = []
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isNetworkAvailable = true

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Reduced accuracy for faster updates
        locationManager.distanceFilter = 100 // Update only when moved 100 meters
        
        // Set up network monitoring
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
    deinit {
        networkMonitor.cancel()
    }

    // Initiates hospital search based on location permissions
    func findHospitals() {
        // Check network connectivity first
        guard isNetworkAvailable else {
            return
        }
        
        // Check if we need to update location
        if let lastUpdate = lastLocationUpdate,
           Date().timeIntervalSince(lastUpdate) < locationUpdateInterval,
           userLocation != nil {
            return // Use cached location
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
            // Handle denied case - could show an alert here
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }

   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.lastLocationUpdate = Date()
        }

        // Search for nearby hospitals with a smaller radius for faster results
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Hospital"
        request.region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 3000, // Reduced from 5000
                                            longitudinalMeters: 3000) // Reduced from 5000

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let items = response?.mapItems else { return }

            let hospitalResults = items.map {
                HospitalLocation(name: $0.name ?? "Hospital",
                                 coordinate: $0.placemark.coordinate,
                                 mapItem: $0)
            }

            DispatchQueue.main.async {
                self.hospitals = hospitalResults
            }
        }
    }

    // Handles location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    // Updates authorization status and requests location if authorized
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
}
