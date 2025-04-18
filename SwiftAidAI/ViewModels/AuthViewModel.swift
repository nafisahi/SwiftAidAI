import Foundation
import Firebase
@preconcurrency import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String = ""
    @Published var isVerificationRequired: Bool = false
    @Published var tempUser: FirebaseAuth.User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
            // Check if user is verified
            if let user = userSession {
                let doc = try? await Firestore.firestore().collection("emailVerifications").document(user.email ?? "").getDocument()
                if doc?.exists == true {
                    // If verification is pending, sign out the user
                    try? Auth.auth().signOut()
                    self.userSession = nil
                    self.currentUser = nil
                }
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.tempUser = result.user
            self.isVerificationRequired = true
            
            let code = generateVerificationCode()
            try await storeVerificationCode(email: email, code: code)
            sendVerificationCodeWithBrevo(to: email, code: code)
            
        } catch {
            self.errorMessage = "Email or password is incorrect."
            throw error
        }
    }
    
    func verifyCode(_ code: String) async throws {
        if let tempUser = tempUser {
            let doc = try await Firestore.firestore().collection("emailVerifications").document(tempUser.email ?? "").getDocument()
            
            guard let data = doc.data(),
                  let storedCode = data["code"] as? String,
                  let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
                  Date() < expiresAt else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Code expired or invalid"])
            }
            
            if code == storedCode {
                self.userSession = tempUser
                self.tempUser = nil
                self.isVerificationRequired = false
                
                try await Firestore.firestore().collection("emailVerifications").document(tempUser.email ?? "").delete()
                try await Firestore.firestore().collection("users").document(tempUser.uid).updateData([
                    "lastLoginAt": Date().description
                ])
                
                await fetchUser()
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
            }
        } else {
            let tempUsers = try await Firestore.firestore().collection("tempUsers").getDocuments()
            guard let email = tempUsers.documents.last?.documentID else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No pending verification found"])
            }
            
            let doc = try await Firestore.firestore().collection("emailVerifications").document(email).getDocument()
            
            guard let data = doc.data(),
                  let storedCode = data["code"] as? String,
                  let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
                  Date() < expiresAt else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Code expired or invalid"])
            }
            
            if code == storedCode {
                let tempUserDoc = try await Firestore.firestore().collection("tempUsers").document(email).getDocument()
                guard let tempUserData = tempUserDoc.data(),
                      let password = tempUserData["password"] as? String,
                      let fullname = tempUserData["fullname"] as? String else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
                }
                
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = result.user
                
                let user = User(
                    id: result.user.uid,
                    fullname: fullname,
                    email: email,
                    createdAt: result.user.metadata.creationDate?.description ?? Date().description,
                    lastLoginAt: result.user.metadata.lastSignInDate?.description ?? Date().description
                )
                
                let encodedUser = try Firestore.Encoder().encode(user)
                try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
                
                try await Firestore.firestore().collection("tempUsers").document(email).delete()
                try await Firestore.firestore().collection("emailVerifications").document(email).delete()
                
                self.tempUser = nil
                self.isVerificationRequired = false
                
                await fetchUser()
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let tempUserData: [String: Any] = [
                "email": email,
                "password": password,
                "fullname": fullname,
                "createdAt": Date().description
            ]
            
            try await Firestore.firestore().collection("tempUsers").document(email).setData(tempUserData)
            
            let code = generateVerificationCode()
            try await storeVerificationCode(email: email, code: code)
            sendVerificationCodeWithBrevo(to: email, code: code)
            
            DispatchQueue.main.async {
                self.isVerificationRequired = true
                self.tempUser = nil
            }
            
        } catch {
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.isVerificationRequired = false
            self.tempUser = nil
        } catch {
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            // Delete user data from Firestore
            try await Firestore.firestore().collection("users").document(user.uid).delete()
            
            // Delete the user account
            try await user.delete()
            
            // Update local state
            self.userSession = nil
            self.currentUser = nil
            self.isVerificationRequired = false
            self.tempUser = nil
            
        } catch {
            throw error
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try? snapshot.data(as: User.self)
        } catch {
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
    
    // Helper functions for verification code
    public func generateVerificationCode() -> String {
        return String(format: "%06d", Int.random(in: 0...999999))
    }
    
    public func storeVerificationCode(email: String, code: String) async throws {
        let expiry = Date().addingTimeInterval(600) // 10 mins
        try await Firestore.firestore().collection("emailVerifications").document(email).setData([
            "code": code,
            "expiresAt": expiry
        ])
    }
    
    public func sendVerificationCodeWithBrevo(to email: String, code: String) {
        guard let url = URL(string: "https://api.brevo.com/v3/smtp/email") else { return }
        
        let payload: [String: Any] = [
            "sender": ["name": "SwiftAidAI", "email": "swiftaidai.verify@gmail.com"],
            "to": [["email": email]],
            "subject": "Your SwiftAidAI Verification Code",
            "htmlContent": """
                <h2>Email Verification</h2>
                <p>Your code is: <strong>\(code)</strong></p>
                <p>This code will expire in 10 minutes.</p>
            """
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Get API key from build settings
        if let apiKeyPath = Bundle.main.path(forResource: "secrets", ofType: "xcconfig"),
           let apiKeyContents = try? String(contentsOfFile: apiKeyPath),
           let apiKey = apiKeyContents.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespacesAndNewlines) {
            request.setValue(apiKey, forHTTPHeaderField: "api-key")
        } else {
            return
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
