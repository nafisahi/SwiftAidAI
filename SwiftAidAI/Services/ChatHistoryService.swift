import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatHistoryService: ObservableObject {
    private let db = Firestore.firestore() // Firestore database reference
    
    // Saves a message to the Firestore database
    func saveMessage(_ message: ChatMessage, conversationId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is authenticated
        
        let messageData: [String: Any] = [
            "id": message.id,
            "text": message.text,
            "isUser": message.isUser,
            "timestamp": Timestamp(date: message.timestamp)
        ]
        
        // Save message data to Firestore
        db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(message.id)
            .setData(messageData) { error in
                // Remove print("Error saving message: \(error.localizedDescription)")
            }
    }
    
    // Saves metadata for a conversation
    func saveConversationMetadata(conversationId: String, title: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is authenticated
        
        let now = Date()
        let metadata: [String: Any] = [
            "title": title,
            "created": Timestamp(date: now),
            "updated": Timestamp(date: now)
        ]
        
        // Save conversation metadata to Firestore
        db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
            .setData(metadata, merge: true) { error in
                // Remove print("Error saving metadata: \(error.localizedDescription)")
            }
    }
    
    // Updates the timestamp of a conversation
    func updateConversationTimestamp(conversationId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is authenticated
        
        // Update the 'updated' field in Firestore
        db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
            .updateData(["updated": Timestamp(date: Date())])
    }
    
    // Loads messages for a specific conversation
    func loadMessages(conversationId: String, completion: @escaping ([ChatMessage]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is authenticated
        
        // Fetch messages from Firestore
        db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .getDocuments { snapshot, error in
                if let error = error {
                    // Remove print("Error loading messages: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                // Map Firestore documents to ChatMessage objects
                let messages = snapshot?.documents.compactMap { document -> ChatMessage? in
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let text = data["text"] as? String,
                          let isUser = data["isUser"] as? Bool,
                          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                        return nil
                    }
                    return ChatMessage(id: id, text: text, isUser: isUser, timestamp: timestamp)
                } ?? []
                
                completion(messages)
            }
    }
    
    // Fetches conversation IDs for the current user
    func fetchConversationIds(completion: @escaping ([String]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        // Retrieve conversation IDs from Firestore
        db.collection("users")
            .document(userId)
            .collection("conversations")
            .order(by: "updated", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    // Remove print("Error fetching conversation IDs: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let ids = snapshot?.documents.map { $0.documentID } ?? []
                completion(ids)
            }
    }
    
    // Deletes a conversation and its messages
    func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let conversationRef = db.collection("users")
            .document(userId)
            .collection("conversations")
            .document(conversationId)
        
        // First delete all messages
        conversationRef.collection("messages").getDocuments { snapshot, error in
            snapshot?.documents.forEach { doc in
                doc.reference.delete() // Delete each message document
            }
            
            // Then delete the conversation document
            conversationRef.delete { error in
                completion(error == nil) // Return success status
            }
        }
    }
} 