import SwiftUI
import FirebaseAuth

// Main profile view that displays user information and account management options
struct ProfileView: View {
    // Authentication view model for user data and actions
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // State variables for account deletion flow
    @State private var showDeleteAlert = false
    @State private var showPasswordConfirmation = false
    @State private var showDeletionMessage = false
    @State private var confirmationPassword = ""
    @State private var showPasswordError = false
    @State private var showLogoutAlert = false
    
    // Environment variable for dismissing the view
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // User profile header with image and name
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("\(authViewModel.currentUser?.fullname ?? "Unknown User")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                // Section displaying user's email information
                Section(header: Text("Account Information")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authViewModel.currentUser?.email ?? "Unknown Email")
                            .foregroundColor(.gray)
                    }
                }
                
                // Section containing account management actions
                Section {
                    // Logout button with confirmation alert
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Log Out")
                            .foregroundColor(.blue)
                    }
                    .alert("Log Out", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Log Out", role: .destructive) {
                            authViewModel.signOut()
                        }
                    } message: {
                        Text("Are you sure you want to log out? You can always sign back in later.")
                    }
                    
                    // Delete account button with confirmation flow
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("This action cannot be undone. Would you like to proceed?"),
                            primaryButton: .destructive(Text("Continue")) {
                                showPasswordConfirmation = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                // Success message shown after account deletion
                if showDeletionMessage {
                    Section {
                        Text("Your account has been successfully deleted. Thank you for using our service!")
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Back button in navigation bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            // Password confirmation sheet for account deletion
            .sheet(isPresented: $showPasswordConfirmation) {
                NavigationView {
                    VStack(spacing: 20) {
                        // Warning icon
                        Image(systemName: "exclamationmark.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding(.top, 30)
                        
                        // Confirmation title and description
                        Text("Confirm Account Deletion")
                            .font(.title2)
                            .bold()
                        
                        Text("Please enter your password to confirm account deletion")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Password input field
                        SecureField("Enter your password", text: $confirmationPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            .padding(.horizontal)
                        
                        // Error message for incorrect password
                        if showPasswordError {
                            Text("Incorrect password. Please try again.")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Action buttons for confirmation sheet
                        HStack(spacing: 15) {
                            // Cancel button
                            Button(action: {
                                showPasswordConfirmation = false
                                confirmationPassword = ""
                                showPasswordError = false
                            }) {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                            
                            // Delete account button with reauthentication
                            Button(action: {
                                Task {
                                    do {
                                        // Reauthenticate user with Firebase Auth
                                        let credential = EmailAuthProvider.credential(
                                            withEmail: authViewModel.currentUser?.email ?? "",
                                            password: confirmationPassword
                                        )
                                        
                                        try await Auth.auth().currentUser?.reauthenticate(with: credential)
                                        
                                        // If reauthentication succeeds, delete the account
                                        try await authViewModel.deleteAccount()
                                        showPasswordConfirmation = false
                                        showDeletionMessage = true
                                        authViewModel.signOut()
                                    } catch {
                                        showPasswordError = true
                                    }
                                }
                            }) {
                                Text("Delete Account")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showPasswordConfirmation = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
} 