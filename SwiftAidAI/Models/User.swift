import Foundation

// User model representing a SwiftAidAI user with authentication and profile information
struct User: Identifiable, Codable {
    
    var id: String
    var fullname: String
    var email: String
    // Timestamp of when the user account was created
    var createdAt: String
    // Timestamp of the user's last login
    var lastLoginAt: String
    // Computed property that generates user's initials from their full name
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        let fullName = "\(fullname)"
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}


