import SwiftUI

// A simple warning note component with an icon and text
struct WarningNote: View {
    // Warning message text
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.subheadline)
            
            // Warning text
            Text(text)
                .font(.subheadline)
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }
}