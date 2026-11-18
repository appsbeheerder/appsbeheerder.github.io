import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate = CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041) // standaard: Amsterdam
    @Published var timeZone: TimeZone = .current
    @Published var placeName = "Amsterdam (standaard)"
    @Published var denied = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced // grove locatie is genoeg
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .denied, .restricted: denied = true
        default: manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: denied = false; manager.requestLocation()
        case .denied, .restricted: denied = true
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        coordinate = loc.coordinate
        placeName = "Huidige locatie"
        geocoder.reverseGeocodeLocation(loc) { [weak self] marks, _ in
            guard let self, let p = marks?.first else { return }
            DispatchQueue.main.async {
                if let tz = p.timeZone { self.timeZone = tz }
                self.placeName = p.locality ?? p.name ?? "Huidige locatie"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Bij een fout blijft de standaardlocatie (Amsterdam) staan.
    }
}
