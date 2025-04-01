import SwiftUI

struct CheckboxRow: View {
    let text: String
    let isChecked: Bool
    let action: () -> Void
    
    // Add computed property to check if this row needs emergency buttons
    private var needsEmergencyButtons: Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Existing checkbox button
            Button(action: action) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(isChecked ? .green : .gray)
                        .font(.system(size: 20))
                    
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
            
            // Add emergency call buttons if needed
            if needsEmergencyButtons {
                SharedEmergencyCallButtons()
                    .padding(.leading, 28) // Align with text
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    CheckboxRow(
        text: "Call 999 or 112 immediately",
        isChecked: false,
        action: {}
    )
} 