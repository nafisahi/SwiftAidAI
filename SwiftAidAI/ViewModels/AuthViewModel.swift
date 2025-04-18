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
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.tempUser = result.user
            self.isVerificationRequired = true
            
            // Don't set userSession yet, wait for verification
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
            self.errorMessage = "Email or password is incorrect."
            throw error
        }
    }
    
    func verifyCode(_ code: String) async throws {
        // In a real implementation, you would verify the code with your backend
        // For now, we'll just simulate a successful verification
        if code == "123456" {
            if let tempUser = tempUser {
                self.userSession = tempUser
                self.tempUser = nil
                self.isVerificationRequired = false
                
                // Update last login time
                let db = Firestore.firestore()
                try await db.collection("users").document(tempUser.uid).updateData([
                    "lastLoginAt": Date().description
                ])
                
                await fetchUser()
            }
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.tempUser = result.user
            self.isVerificationRequired = true
            
            let user = User(
                id: result.user.uid,
                fullname: fullname,
                email: email,
                createdAt: result.user.metadata.creationDate?.description ?? Date().description,
                lastLoginAt: result.user.metadata.lastSignInDate?.description ?? Date().description
            )
            
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            // Don't set userSession yet, wait for verification
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete user data from Firestore
        try await Firestore.firestore().collection("users").document(user.uid).delete()
        
        // Delete user from Firebase Authentication
        try await user.delete()
        
        // Clear local session
        self.userSession = nil
        self.currentUser = nil
    }
    
    func fetchUser() async {
        guard let uid = userSession?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if let userData = snapshot.data() {
                self.currentUser = try? Firestore.Decoder().decode(User.self, from: userData)
            }
        } catch {
            print("DEBUG: Failed to fetch user with error \(error.localizedDescription)")
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send password reset email with error \(error.localizedDescription)")
            throw error
        }
    }
}
