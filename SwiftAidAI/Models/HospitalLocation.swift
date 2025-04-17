import Foundation
import MapKit

// Model representing a hospital location with identifying information and map data
struct HospitalLocation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
    
    static func == (lhs: HospitalLocation, rhs: HospitalLocation) -> Bool {
        lhs.id == rhs.id
    }
}
