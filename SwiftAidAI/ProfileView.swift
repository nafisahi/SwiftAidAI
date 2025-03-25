import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showDeleteAlert = false
    @State private var showConfirmDialog = false
    @State private var showDeletionMessage = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Image and Name
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.purple)
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
                        authViewModel.signOut()
                        // Handle post sign-out actions, e.g., navigate to login view
                    }) {
                        Text("Log Out")
                            .foregroundColor(.blue)
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
                            message: Text("Are you sure you want to delete your account?"),
                            primaryButton: .destructive(Text("Delete")) {
                                showConfirmDialog = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .confirmationDialog("Confirm Account Deletion", isPresented: $showConfirmDialog) {
                        Button("Confirm", role: .destructive) {
                            Task {
                                do {
                                    try await authViewModel.deleteAccount()
                                    authViewModel.signOut()
                                    showDeletionMessage = true
                                } catch {
                                    print("Failed to delete account: \(error.localizedDescription)")
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
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
        }
    }
}

#Preview {
    ProfileView()
} 