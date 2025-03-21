import Foundation

struct User {
    var firstName: String
    var surname: String
    var email: String
    var password: String
    
    // Computed property for initials
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        let fullName = "\(firstName) \(surname)"
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
        firstName: "Kobe",
        surname: "Bryant",
        email: "test@gmail.com",
        password: "password123" // Add a mock password
    )
}
