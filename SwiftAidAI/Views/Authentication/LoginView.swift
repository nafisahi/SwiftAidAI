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
    @State private var showVerificationView = false
    
    @State private var showForgotPasswordSheet = false
    @State private var resetEmailSent = false
    @State private var resetEmail: String = ""
    @State private var resetEmailError: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 25) {
                    logoSection
                    loginFormSection
                    forgotPasswordSection
                    buttonsSection
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
        .navigationDestination(isPresented: $showVerificationView) {
            VerificationCodeView(email: email) {
                // Remove navigation to profile, let ContentView handle it
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.3), Color.white]),
                      startPoint: .top,
                      endPoint: .bottom)
            .ignoresSafeArea()
    }
    
    private var logoSection: some View {
        Image("namelogo")
            .resizable()
            .scaledToFit()
            .frame(width: 275, height: 275)
            .padding(.bottom, 5)
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            emailField
            passwordField
        }
    }
    
    private var emailField: some View {
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
    }
    
    private var passwordField: some View {
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
    }
    
    private var forgotPasswordSection: some View {
        HStack {
            Spacer()
            Button(action: {
                resetEmail = email
                showForgotPasswordSheet = true
            }) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(.teal)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showForgotPasswordSheet) {
            ForgotPasswordSheet(
                resetEmail: $resetEmail,
                resetEmailError: $resetEmailError,
                resetEmailSent: $resetEmailSent,
                showSheet: $showForgotPasswordSheet,
                authViewModel: authViewModel
            )
        }
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 15) {
            loginButton
            googleSignInButton
            signUpLink
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            Task {
                do {
                    try await authViewModel.signIn(withEmail: email, password: password)
                    showVerificationView = true
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
                .background(isFormValid ? Color.teal : Color.gray)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5)
                .padding(.horizontal)
        }
        .disabled(!isFormValid)
        .alert("Oops!", isPresented: $showLoginError) {
            Button("Try Again", role: .cancel) {
                password = ""
            }
        } message: {
            Text(loginErrorMessage)
        }
    }
    
    private var googleSignInButton: some View {
        Button(action: {
            Task {
                do {
                    try await authViewModel.signInWithGoogle()
                } catch {
                    loginErrorMessage = "Failed to sign in with Google. Please try again."
                    showLoginError = true
                }
            }
        }) {
            HStack(spacing: 12) {
                Image("google_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Sign in with Google")
                    .font(.body)
                    .foregroundColor(.black.opacity(0.75))
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
        }
        .padding(.horizontal)
    }
    
    private var signUpLink: some View {
        NavigationLink(destination: SignUpView()) {
            Text("Don't have an account? ")
                .font(.subheadline)
                .foregroundColor(.teal) +
            Text("Create one now!")
                .font(.subheadline)
                .bold()
                .foregroundColor(.teal)
        }
    }
    
    // MARK: - Validation Functions
    
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

// MARK: - Supporting Views

struct ForgotPasswordSheet: View {
    @Binding var resetEmail: String
    @Binding var resetEmailError: String
    @Binding var resetEmailSent: Bool
    @Binding var showSheet: Bool
    var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 50))
                    .foregroundColor(.teal)
                    .padding(.top, 30)
                
                Text("Reset Password")
                    .font(.title2)
                    .bold()
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                resetEmailField
                resetButton
                successMessage
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Close") {
                showSheet = false
                resetEmailSent = false
                resetEmailError = ""
            })
        }
    }
    
    private var resetEmailField: some View {
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
    }
    
    private var resetButton: some View {
        Button(action: {
            Task {
                do {
                    try await authViewModel.resetPassword(withEmail: resetEmail)
                    resetEmailSent = true
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
                .background(Color.teal)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private var successMessage: some View {
        Group {
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
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
} 
