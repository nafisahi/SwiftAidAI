import CoreLocation
import MessageUI

// Class to handle emergency message generation and location updates
class EmergencyMessageHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager() // Location manager instance for tracking location
    private var locationCallback: ((String) -> Void)? // Callback for location updates
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy for location
    }

    // Function to generate the emergency message
    func generateMessage(name: String, contacts: [EmergencyContact], completion: @escaping (MFMessageComposeViewController?) -> Void) {
        // Reset any existing callback
        locationCallback = nil
        
        // Define the callback for location updates
        self.locationCallback = { [weak self] message in
            guard MFMessageComposeViewController.canSendText() else {
                completion(nil) // Return nil if messages can't be sent
                return
            }

            let vc = MFMessageComposeViewController() // Create message compose view controller
            vc.body = message // Set the message body
            vc.recipients = contacts.filter { $0.isSelected }.map { $0.phoneNumber } // Set recipients
            vc.messageComposeDelegate = self // Set delegate
            completion(vc) // Return the view controller
        }

        // Check if location is allowed
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.delegate = self // Set delegate for location updates
            locationManager.requestLocation() // Request current location
        default:
            // Location not allowed – fallback message
            let fallback = """
            🚨 Emergency Alert 🚨

            Hi! This is an urgent message sent through SwiftAidAI.

            I may need your help right now and have chosen you as my emergency contact.

            Unfortunately, my location couldn't be shared. Please reach out to me as soon as possible to make sure I'm okay!
            """
            self.locationCallback?(fallback) // Call the fallback message
        }
    }

    // Location update handler
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.first?.coordinate else {
            self.locationCallback?("🚨 Emergency Alert 🚨\n\nHi! We had trouble getting the location. Please check on me when you can!")
            return
        }

        let locationLink = "https://www.google.com/maps?q=\(coord.latitude),\(coord.longitude)" // Create a link to the location

        let message = """
        🚨 Emergency Alert 🚨

        Hi! This is an urgent message sent through SwiftAidAI.

        I may need your help right now and have chosen you as my emergency contact.

        You can find my last known location here:
        \(locationLink)

        Please check on me when you can!
        """

        self.locationCallback?(message) // Call the message with location
        // Clean up location manager
        locationManager.delegate = nil
    }

    // Location failure handler
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let fallback = """
        🚨 Emergency Alert 🚨

        Hi! This is an urgent message sent through SwiftAidAI.

        I couldn't determine my exact location right now. Please reach out to check if I'm okay!
        """
        self.locationCallback?(fallback) // Call the fallback message
        // Clean up location manager
        locationManager.delegate = nil
    }
}

// MessageUI delegate stub
extension EmergencyMessageHelper: MFMessageComposeViewControllerDelegate {
    // Delegate method to handle the result of the message compose view controller
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) // Dismiss the message compose view controller
    }
} 