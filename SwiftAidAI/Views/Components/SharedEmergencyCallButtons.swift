import SwiftUI

struct SharedEmergencyCallButtons: View {
    @State private var showingCallAlert = false
    @State private var selectedNumber = ""
    @State private var alertMessage = ""
    
    var body: some View {
        HStack(spacing: 20) {
            // 999 Button
            SharedEmergencyCallButton(
                number: "999",
                icon: "phone.fill",
                color: .red,
                showingAlert: $showingCallAlert,
                selectedNumber: $selectedNumber,
                alertMessage: $alertMessage
            )
            
            // 112 Button
            SharedEmergencyCallButton(
                number: "112",
                icon: "phone.fill",
                color: .blue,
                showingAlert: $showingCallAlert,
                selectedNumber: $selectedNumber,
                alertMessage: $alertMessage
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.clear)
        .alert("Emergency Call", isPresented: $showingCallAlert) {
            Button("Call \(selectedNumber)", role: .destructive) {
                if let url = URL(string: "tel://\(selectedNumber)") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

private struct SharedEmergencyCallButton: View {
    let number: String
    let icon: String
    let color: Color
    @Binding var showingAlert: Bool
    @Binding var selectedNumber: String
    @Binding var alertMessage: String
    
    var body: some View {
        Button(action: {
            selectedNumber = number
            alertMessage = "Are you sure you want to call \(number)?"
            showingAlert = true
        }) {
            Label(number, systemImage: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .cornerRadius(12)
        }
    }
}

#Preview {
    SharedEmergencyCallButtons()
} 