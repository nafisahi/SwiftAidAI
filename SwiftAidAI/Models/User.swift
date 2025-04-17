import Foundation

struct User: Identifiable, Codable {
    var id: String
    var fullname: String
    var email: String
    var createdAt: String
    var lastLoginAt: String
    
    // Computed property for initials
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        let fullName = "\(fullname)"
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
    // Add any additional user-related properties or methods here
}

extension User {
    static var MOCK_USER = User(
        id: "mockUserId",
        fullname: "Kobe Bryant",
        email: "test@gmail.com",
        createdAt: Date().description,
        lastLoginAt: Date().description
    )
}
