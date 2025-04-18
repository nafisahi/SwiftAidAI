import SwiftUI
import ContactsUI

// A struct to present a contact picker for selecting contacts
struct ContactPicker: UIViewControllerRepresentable {
    var onSelect: (String, String) -> Void  
    var selectedCount: Int 
    let maxContacts = 5 

    // Creates a coordinator to manage the contact picker
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates the contact picker view controller
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController() 
        picker.delegate = context.coordinator // Set the coordinator as the delegate
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0") // Enable only contacts with phone numbers
        return picker // Return the configured contact picker
    }

    // Updates the view controller when the state changes
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    // Coordinator class to handle contact picker delegate methods
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPicker 

        init(_ parent: ContactPicker) {
            self.parent = parent 
        }

        // Called when a contact is selected
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            guard let number = contact.phoneNumbers.first?.value.stringValue else { return } 
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "Unknown" 
            
            // Call the onSelect callback if the max contact limit is not reached
            if parent.selectedCount < parent.maxContacts {
                parent.onSelect(name, number) 
            }
        }
    }
} 