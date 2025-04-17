import SwiftUI
import MapKit

// Main view for displaying nearby hospitals in emergency situations
struct EmergencyAlertView: View {
    @StateObject private var viewModel = LocationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHospital: HospitalLocation?

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Show appropriate view based on network and location authorization status
                    if !viewModel.isNetworkAvailable {
                        OfflineView()
                    } else if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                        LocationDeniedView()
                    } else if let userLocation = viewModel.userLocation {
                        // Map View showing hospitals and user location
                        HospitalMapView(
                            userLocation: userLocation,
                            hospitals: viewModel.hospitals,
                            selectedHospital: $selectedHospital,
                            height: geometry.size.height * 0.5
                        )
                        
                        // Header showing number of hospitals found
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nearby Hospitals")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("\(viewModel.hospitals.count) locations found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)
                        
                        // Scrollable list of hospitals sorted by distance
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(sortedHospitals(for: userLocation, hospitals: viewModel.hospitals)) { hospital in
                                        HospitalRowView(
                                            hospital: hospital,
                                            userLocation: userLocation,
                                            isSelected: selectedHospital?.id == hospital.id
                                        )
                                        .id(hospital.id)
                                        .transition(.opacity)
                                    }
                                }
                            }
                            .onChange(of: selectedHospital) { hospital in
                                if let hospital = hospital {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        scrollProxy.scrollTo(hospital.id, anchor: .top)
                                    }
                                }
                            }
                        }
                    } else if viewModel.authorizationStatus == .notDetermined {
                        LocationPermissionView()
                    }
                }
            }
            .navigationTitle("Nearby Hospitals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Only request location if we don't have one
            if viewModel.userLocation == nil {
                viewModel.findHospitals()
            }
        }
    }
    
    // Helper function to sort hospitals by distance from user
    private func sortedHospitals(for userLocation: CLLocationCoordinate2D, hospitals: [HospitalLocation]) -> [HospitalLocation] {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return hospitals.sorted { hospital1, hospital2 in
            let location1 = CLLocation(latitude: hospital1.coordinate.latitude, longitude: hospital1.coordinate.longitude)
            let location2 = CLLocation(latitude: hospital2.coordinate.latitude, longitude: hospital2.coordinate.longitude)
            return location1.distance(from: userCLLocation) < location2.distance(from: userCLLocation)
        }
    }
}

// Map view component showing hospital locations
struct HospitalMapView: View {
    let userLocation: CLLocationCoordinate2D
    let hospitals: [HospitalLocation]
    @Binding var selectedHospital: HospitalLocation?
    let height: CGFloat
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )),
        showsUserLocation: true,
        annotationItems: hospitals) { hospital in
            MapAnnotation(coordinate: hospital.coordinate) {
                Button(action: {
                    withAnimation {
                        selectedHospital = hospital
                    }
                }) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "cross.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                }
            }
        }
        .frame(height: height)
        .edgesIgnoringSafeArea(.horizontal)
    }
}

// List view component showing hospital details
struct HospitalListView: View {
    let userLocation: CLLocationCoordinate2D
    let hospitals: [HospitalLocation]
    @Binding var selectedHospital: HospitalLocation?
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    Text("Nearby Hospitals")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.top)

                    ForEach(sortedHospitals()) { hospital in
                        HospitalRowView(
                            hospital: hospital,
                            userLocation: userLocation,
                            isSelected: selectedHospital?.id == hospital.id
                        )
                        .id(hospital.id)
                    }
                }
            }
            .background(Color(.systemBackground))
            .onChange(of: selectedHospital) { hospital in
                if let hospital = hospital {
                    withAnimation(.easeOut(duration: 0.3)) {
                        scrollProxy.scrollTo(hospital.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    // Helper function to sort hospitals by distance
    private func sortedHospitals() -> [HospitalLocation] {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return hospitals.sorted { hospital1, hospital2 in
            let location1 = CLLocation(latitude: hospital1.coordinate.latitude, longitude: hospital1.coordinate.longitude)
            let location2 = CLLocation(latitude: hospital2.coordinate.latitude, longitude: hospital2.coordinate.longitude)
            return location1.distance(from: userCLLocation) < location2.distance(from: userCLLocation)
        }
    }
}

// Individual hospital row component
struct HospitalRowView: View {
    let hospital: HospitalLocation
    let userLocation: CLLocationCoordinate2D
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            openInMaps(hospital.mapItem)
        }) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "cross.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(formatDistance())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(isSelected ? Color(.systemGray6) : Color(.systemBackground))
            )
        }
    }
    
    // Helper function to format distance in miles
    private func formatDistance() -> String {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let hospitalCLLocation = CLLocation(latitude: hospital.coordinate.latitude, longitude: hospital.coordinate.longitude)
        let distance = userCLLocation.distance(from: hospitalCLLocation)
        
        let miles = distance / 1609.34
        return String(format: "%.1f mi", miles)
    }
    
    // Helper function to open directions in Maps app
    private func openInMaps(_ mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// View shown when location access is denied
struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Location Access Required")
                .font(.headline)
            
            Text("Please enable location access in Settings to find nearby hospitals.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// View shown when requesting initial location permission
struct LocationPermissionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Location Access Needed")
                .font(.headline)
            
            Text("SwiftAidAI needs your location to find nearby hospitals.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// View shown when there's no network connectivity
struct OfflineView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Find Nearest Hospital Unavailable")
                .font(.title2)
                .bold()
            
            Text("Please check your internet connection to use the Find Nearest Hospital feature.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmergencyAlertView()
} 