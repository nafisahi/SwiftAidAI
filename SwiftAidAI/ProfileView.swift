import SwiftUI

struct ProfileView: View {
    @State private var user: User = User.MOCK_USER
    
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
                    
                    Text("\(user.firstName) \(user.surname)")
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
                        Text(user.email)
                            .foregroundColor(.gray)
                    }
                }
                
                // Actions
                Section {
                    Button(action: {
                        // Handle log out action
                    }) {
                        Text("Log Out")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        // Handle delete account action
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
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