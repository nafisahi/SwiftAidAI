import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// Service class to manage emergency contacts
class EmergencyContactService: ObservableObject {
    private let db = Firestore.firestore() // Firestore database instance
    
    // Function to save emergency contacts to Firestore
    func saveContacts(_ contacts: [EmergencyContact]) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        print("👤 Saving contacts for user: \(userId)")
        
        // Map contacts to a dictionary format for Firestore
        let contactsData = contacts.map { contact -> [String: Any] in
            return [
                "id": contact.id.uuidString,
                "name": contact.name,
                "phoneNumber": contact.phoneNumber,
                "isSelected": contact.isSelected
            ]
        }
        
        // Create a batch write 
        let batch = db.batch()
        
        // Reference to the contacts document in Firestore
        let contactsRef = db.collection("users")
            .document(userId)
            .collection("emergency_contacts")
            .document("contacts")
        
        // Set the contacts data in Firestore
        batch.setData(["contacts": contactsData], forDocument: contactsRef)
        
        // Commit the batch write
        batch.commit { error in
            if let error = error {
                print(" Error saving contacts: \(error.localizedDescription)")
            } else {
                print("Successfully saved contacts to Firebase")
            }
        }
    }
    
    // Function to load emergency contacts from Firestore
    func loadContacts(completion: @escaping ([EmergencyContact]) -> Void) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            completion([]) // Return empty array if not authenticated
            return
        }
        
        print("Loading contacts for user: \(userId)")
        
        // Fetch contacts document from Firestore
        db.collection("users")
            .document(userId)
            .collection("emergency_contacts")
            .document("contacts")
            .getDocument { snapshot, error in
                if let error = error {
                    print(" Error loading contacts: \(error.localizedDescription)")
                    completion([]) // Return empty array on error
                    return
                }
                
                // Check if contacts data exists
                guard let data = snapshot?.data(),
                      let contactsData = data["contacts"] as? [[String: Any]] else {
                    print("ℹNo contacts found for user")
                    completion([]) // Return empty array if no contacts
                    return
                }
                
                // Map the contacts data to EmergencyContact objects
                let contacts = contactsData.compactMap { contactData -> EmergencyContact? in
                    guard let name = contactData["name"] as? String,
                          let phoneNumber = contactData["phoneNumber"] as? String,
                          let isSelected = contactData["isSelected"] as? Bool else {
                        print("Invalid contact data format")
                        return nil // Return nil for invalid data
                    }
                    return EmergencyContact(name: name, phoneNumber: phoneNumber, isSelected: isSelected)
                }
                
                print("Successfully loaded \(contacts.count) contacts")
                completion(contacts) // Return the loaded contacts
            }
    }
} 