import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var firstName: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Validation states
    @State private var firstNameError: String = ""
    @State private var surnameError: String = ""
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var confirmPasswordError: String = ""
    @State private var isFormValid: Bool = false
    @State private var showEmailInUseAlert: Bool = false
    @State private var navigateToLogin: Bool = false
    @State private var showVerificationView: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), 
                               startPoint: .top, 
                               endPoint: .bottom)
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Create Account")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.blue)
                                .padding(.top, 20)

                            // First name and surname in horizontal arrangement
                            HStack(spacing: 15) {
                                // First name field with validation
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("First Name")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                    
                                    TextField("First Name", text: $firstName)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: .black.opacity(0.1), radius: 5)
                                        .onChange(of: firstName) { validateFirstName() }
                                    
                                    if !firstNameError.isEmpty {
                                        Text(firstNameError)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.leading, 4)
                                    }
                                }
                                
                                // Surname field with validation
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Surname")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                    
                                    TextField("Surname", text: $surname)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: .black.opacity(0.1), radius: 5)
                                        .onChange(of: surname) { validateSurname() }
                                    
                                    if !surnameError.isEmpty {
                                        Text(surnameError)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.leading, 4)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Email field with validation
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 5)
                                
                                TextField("Email", text: $email)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .onChange(of: email) { validateEmail() }
                                    .padding(.horizontal)
                                
                                if !emailError.isEmpty {
                                    Text(emailError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, 9)
                                }
                            }

                            // Password field with validation
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 5)
                                
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                                    .onChange(of: password) { 
                                        validatePassword()
                                        validateConfirmPassword()
                                    }
                                    .padding(.horizontal)
                                
                                if !passwordError.isEmpty {
                                    Text(passwordError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, 9)
                                }
                            }

                            // Confirm password field with validation
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Confirm Password")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 5)
                                
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                                    .onChange(of: confirmPassword) { validateConfirmPassword() }
                                    .padding(.horizontal)
                                
                                if !confirmPasswordError.isEmpty {
                                    Text(confirmPasswordError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, 9)
                                }
                            }

                            // Sign up button
                            Button(action: {
                                Task {
                                    do {
                                        try await authViewModel.createUser(withEmail: email, password: password, fullname: "\(firstName) \(surname)")
                                        showVerificationView = true
                                    } catch let error as NSError {
                                        if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                                            showEmailInUseAlert = true
                                        } else {
                                            print("Sign-up failed: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(isFormValid ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            }
                            .disabled(!isFormValid)
                            .padding(.horizontal)
                            .alert(isPresented: $showEmailInUseAlert) {
                                Alert(
                                    title: Text("Email Already in Use"),
                                    message: Text("There's already an account with this email. Would you like to try logging in?"),
                                    primaryButton: .default(Text("OK")) {
                                        navigateToLogin = true
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            
                            // NavigationLink to LoginView
                            .navigationDestination(isPresented: $navigateToLogin) {
                                LoginView()
                            }
                            
                            // NavigationLink to VerificationCodeView
                            .navigationDestination(isPresented: $showVerificationView) {
                                VerificationCodeView(email: email) {
                                    // Handle successful verification
                                    // You can navigate to the main app view here
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    }
                }
            }
        }
    }
    
    // Validation functions
    private func validateFirstName() {
        if firstName.isEmpty {
            firstNameError = "First name is required"
        } else if firstName.count < 2 {
            firstNameError = "First name is too short"
        } else {
            firstNameError = ""
        }
        
        validateForm()
    }
    
    private func validateSurname() {
        if surname.isEmpty {
            surnameError = "Surname is required"
        } else if surname.count < 2 {
            surnameError = "Surname is too short"
        } else {
            surnameError = ""
        }
        
        validateForm()
    }
    
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
        } else if !password.contains(where: { $0.isNumber }) {
            passwordError = "Password must contain at least one number"
        } else if !password.contains(where: { $0.isUppercase }) {
            passwordError = "Password must contain at least one uppercase letter"
        } else {
            passwordError = ""
        }
        
        validateForm()
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = ""
        }
        
        validateForm()
    }
    
    private func validateForm() {
        isFormValid = firstNameError.isEmpty && surnameError.isEmpty && 
                      emailError.isEmpty && passwordError.isEmpty && 
                      confirmPasswordError.isEmpty && !firstName.isEmpty && 
                      !surname.isEmpty && !email.isEmpty && 
                      !password.isEmpty && !confirmPassword.isEmpty
    }
}

#Preview {
    SignUpView()
} 
