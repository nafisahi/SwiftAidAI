import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Validation states
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var isFormValid: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), 
                               startPoint: .top, 
                               endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    // App logo
                    Image("namelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 5)

                    
                    // Email field with validation
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .onChange(of: email) { validateEmail() }
                        
                        if !emailError.isEmpty {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Password field with validation
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                            .onChange(of: password) { validatePassword() }
                        
                        if !passwordError.isEmpty {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal)

                    // Forgot password link aligned to the right
                    HStack {
                        Spacer()
                        Button(action: {
                            // Handle forgot password action
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)

                    // Login button
                    Button(action: {
                        // Handle login action
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                            .padding(.horizontal)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 10)

                    // Sign up navigation link with bold text
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? ")
                            .font(.subheadline)
                            .foregroundColor(.blue) +
                        Text("Create one now!")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 15)
                }
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // Validation functions
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            emailError = "Email is required"
        } else if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
        
        validateForm()
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
        } else {
            passwordError = ""
        }
        
        validateForm()
    }
    
    private func validateForm() {
        isFormValid = emailError.isEmpty && passwordError.isEmpty && !email.isEmpty && !password.isEmpty
    }
}

#Preview {
    LoginView()
} 
