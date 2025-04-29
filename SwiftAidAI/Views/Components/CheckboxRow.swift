import SwiftUI

// A reusable checkbox row component that displays text with a checkbox
struct CheckboxRow: View {
    // The text to display next to the checkbox
    let text: String
    // Whether the checkbox is checked or not
    let isChecked: Bool
    // Action to perform when the row is tapped
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 8) {
                // Checkbox icon that changes based on checked state
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .green : .gray)
                    .font(.system(size: 20))
                
                // Text content that can wrap to multiple lines
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
}

