import SwiftUI
import MessageUI

// A struct to present a message compose view
struct MessageSheetController: UIViewControllerRepresentable {
    let messageVC: MFMessageComposeViewController // Message view controller
    @Binding var isPresented: Bool // Controls presentation state
    
    // Creates a coordinator for handling delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Creates and configures the message compose view controller
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        messageVC.messageComposeDelegate = context.coordinator // Set delegate
        return messageVC
    }
    
    // Updates the view controller when the state changes
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    // Coordinator class to handle delegate methods for the message compose view controller
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageSheetController
        
        init(_ parent: MessageSheetController) {
            self.parent = parent
        }
        
        // Dismiss the sheet when the user finishes composing the message
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.isPresented = false
        }
    }
} 