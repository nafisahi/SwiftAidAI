import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showDeleteAlert = false
    @State private var showPasswordConfirmation = false
    @State private var showDeletionMessage = false
    @State private var confirmationPassword = ""
    @State private var showPasswordError = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        List {
            // Profile Image and Name
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
            
            // User Details
            Section(header: Text("Account Information")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(authViewModel.currentUser?.email ?? "Unknown Email")
                        .foregroundColor(.gray)
                }
            }
            
            // Actions
            Section {
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
            
            // Deletion Confirmation Message
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
        .sheet(isPresented: $showPasswordConfirmation) {
            NavigationView {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .padding(.top, 30)
                    
                    Text("Confirm Account Deletion")
                        .font(.title2)
                        .bold()
                    
                    Text("Please enter your password to confirm account deletion")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    SecureField("Enter your password", text: $confirmationPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                    
                    if showPasswordError {
                        Text("Incorrect password. Please try again.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 15) {
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
                                    print("Failed to delete account: \(error.localizedDescription)")
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

#Preview {
    NavigationStack {
        ProfileView()
    }
} 