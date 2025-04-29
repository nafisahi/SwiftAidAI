import Foundation

// Represents a single message in a chat conversation
struct ChatMessage: Identifiable, Codable {
    let id: String      // Unique identifier
    let text: String    // Message content
    let isUser: Bool    // True if sent by user, false if AI
    let timestamp: Date // When message was created

    // Initialises a new chat message
    init(id: String = UUID().uuidString, text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
} 