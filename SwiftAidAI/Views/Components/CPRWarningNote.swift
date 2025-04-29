import SwiftUI

// A warning note component that displays CPR instructions and can trigger CPR guidance
struct CPRWarningNote: View {
    // Binding to control whether CPR guidance is shown
    @Binding var showingCPR: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.subheadline)
            
            // Warning text with different colors for emphasis
            (Text("If they become unresponsive, ")
                .foregroundColor(.orange) +
            Text("start CPR")
                .foregroundColor(.red)
                .underline() +
            Text(" immediately.")
                .foregroundColor(.orange))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
        // Tapping the warning shows CPR guidance
        .onTapGesture {
            showingCPR = true
        }
    }
} 