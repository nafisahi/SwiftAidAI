import Foundation

// Metadata for a chat conversation
struct ConversationMetadata: Codable {
    let title: String
    let created: Date
    var updated: Date
} 