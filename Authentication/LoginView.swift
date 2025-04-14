import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Validation states
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var isFormValid: Bool = false
    
    // State to track login status
    @State private var isLoggedIn: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showLoginError = false
    @State private var loginErrorMessage = ""
    
    @State private var showForgotPasswordSheet = false
    @State private var resetEmailSent = false
    @State private var resetEmail: String = ""
    @State private var resetEmailError: String = ""
    
    var body: some View {
        NavigationStack {
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
                            resetEmail = email // Pre-fill with email if already entered
                            showForgotPasswordSheet = true
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showForgotPasswordSheet) {
                        NavigationStack {
                            VStack(spacing: 20) {
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                    .padding(.top, 30)
                                
                                Text("Reset Password")
                                    .font(.title2)
                                    .bold()
                                
                                Text("Enter your email address and we'll send you instructions to reset your password.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("Email", text: $resetEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: .black.opacity(0.1), radius: 5)
                                    
                                    if !resetEmailError.isEmpty {
                                        Text(resetEmailError)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.leading)
                                    }
                                }
                                .padding(.horizontal)
                                
                                Button(action: {
                                    Task {
                                        do {
                                            try await authViewModel.resetPassword(withEmail: resetEmail)
                                            resetEmailSent = true
                                            // We'll keep the sheet open to show success message
                                        } catch {
                                            resetEmailError = "We couldn't find an account with that email. Please check and try again."
                                        }
                                    }
                                }) {
                                    Text("Send Reset Link")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                if resetEmailSent {
                                    VStack(spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 40))
                                        
                                        Text("Reset Link Sent!")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        
                                        Text("Please check your email for instructions to reset your password.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding()
                                }
                                
                                Spacer()
                            }
                            .navigationBarItems(trailing: Button("Close") {
                                showForgotPasswordSheet = false
                                resetEmailSent = false
                                resetEmailError = ""
                            })
                        }
                    }

                    // Login button
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.signIn(withEmail: email, password: password)
                                isLoggedIn = true
                            } catch {
                                loginErrorMessage = "The email or password you entered is incorrect. Please try again."
                                showLoginError = true
                            }
                        }
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
                    .alert("Oops!", isPresented: $showLoginError) {
                        Button("Try Again", role: .cancel) {
                            password = "" // Clear password field for security
                        }
                    } message: {
                        Text(loginErrorMessage)
                    }

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

                    // NavigationLink to ProfileView
                    NavigationLink(value: isLoggedIn) {
                        EmptyView()
                    }
                    .navigationDestination(isPresented: $isLoggedIn) {
                        ProfileView()
                    }
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
            emailError = "Please enter your email address"
        } else if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
        
        validateForm()
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Please enter your password"
        } else if password.count < 6 {
            passwordError = "Your password should be at least 6 characters"
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
