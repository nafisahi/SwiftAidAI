import SwiftUI

struct VerificationCodeView: View {
    @State private var verificationCode: [String] = Array(repeating: "", count: 6)
    @State private var isCodeValid: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var timer: Timer?
    @State private var timeRemaining: Int = 60
    @State private var isResendEnabled: Bool = false
    @State private var showView: Bool = false
    @State private var showBackAlert: Bool = false
    @State private var isResending: Bool = false
    
    let email: String
    let onVerificationComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), 
                               startPoint: .top, 
                               endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Title and description
                    VStack(spacing: 10) {
                        Text("Verify Your Email")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.blue)
                            .transition(.opacity)
                        
                        Text("We've sent a 6-digit code to")
                            .foregroundColor(.gray)
                            .transition(.opacity)
                        
                        Text(email)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .transition(.opacity)
                    }
                    .padding(.top, 40)
                    
                    // Verification code input fields
                    HStack(spacing: 15) {
                        ForEach(0..<6, id: \.self) { index in
                            TextField("", text: $verificationCode[index])
                                .frame(width: 45, height: 55)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: focusedField == index ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), radius: 5)
                                )
                                .focused($focusedField, equals: index)
                                .onChange(of: verificationCode[index]) { newValue in
                                    // Limit to one digit
                                    if newValue.count > 1 {
                                        verificationCode[index] = String(newValue.prefix(1))
                                    }
                                    
                                    // Handle backspace
                                    if newValue.isEmpty && index > 0 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            focusedField = index - 1
                                            // Clear the previous field when backspacing
                                            verificationCode[index - 1] = ""
                                        }
                                    }
                                    // Move to next field if digit entered
                                    else if !newValue.isEmpty && index < 5 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            focusedField = index + 1
                                        }
                                    }
                                    
                                    validateCode()
                                }
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .transition(.opacity)
                    }
                    
                    // Timer and resend button
                    HStack {
                        if !isResendEnabled {
                            Text("Resend code in: \(timeRemaining)s")
                                .foregroundColor(.gray)
                        } else {
                            Button(action: {
                                withAnimation {
                                    resendCode()
                                }
                            }) {
                                if isResending {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                } else {
                                    Text("Resend Code")
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                }
                            }
                            .disabled(isResending)
                        }
                    }
                    .padding(.top, 10)
                    .transition(.opacity)
                    
                    // Verify button
                    Button(action: {
                        withAnimation {
                            verifyCode()
                        }
                    }) {
                        Text("Verify")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isCodeValid ? Color.blue : Color.gray)
                                    .shadow(color: isCodeValid ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3), radius: 5)
                            )
                    }
                    .disabled(!isCodeValid)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .transition(.scale.combined(with: .opacity))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showBackAlert = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert("Go Back?", isPresented: $showBackAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    // Clean up and go back
                    timer?.invalidate()
                    authViewModel.isVerificationRequired = false
                    authViewModel.tempUser = nil
                    dismiss()
                }
            } message: {
                Text("Going back will cancel the verification process. Are you sure?")
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                showView = true
            }
            startTimer()
            // Focus the first field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func validateCode() {
        let code = verificationCode.joined()
        isCodeValid = code.count == 6 && code.allSatisfy { $0.isNumber }
    }
    
    private func verifyCode() {
        let code = verificationCode.joined()
        Task {
            do {
                try await authViewModel.verifyCode(code)
                withAnimation(.easeInOut(duration: 0.5)) {
                    onVerificationComplete()
                }
            } catch {
                withAnimation {
                    showError = true
                    errorMessage = "Invalid verification code. Please try again."
                    // Clear all fields
                    verificationCode = Array(repeating: "", count: 6)
                    // Reset focus to first field
                    focusedField = nil
                    // Small delay to ensure focus reset works
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusedField = 0
                    }
                }
            }
        }
    }
    
    private func resendCode() {
        isResending = true
        Task {
            do {
                // Generate and send new code
                let code = authViewModel.generateVerificationCode()
                try await authViewModel.storeVerificationCode(email: email, code: code)
                authViewModel.sendVerificationCodeWithBrevo(to: email, code: code)
                
                // Reset UI state
                withAnimation {
                    timeRemaining = 60
                    isResendEnabled = false
                    isResending = false
                    verificationCode = Array(repeating: "", count: 6)
                    showError = false
                    // Reset focus to first field
                    focusedField = nil
                    // Small delay to ensure focus reset works
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusedField = 0
                    }
                }
                
                // Restart timer
                startTimer()
            } catch {
                withAnimation {
                    showError = true
                    errorMessage = "Failed to resend code. Please try again."
                    isResending = false
                }
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                withAnimation {
                    isResendEnabled = true
                }
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    VerificationCodeView(email: "test@example.com", onVerificationComplete: {})
        .environmentObject(AuthViewModel())
} 