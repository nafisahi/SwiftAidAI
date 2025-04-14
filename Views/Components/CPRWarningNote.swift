import SwiftUI

struct CPRWarningNote: View {
    @Binding var showingCPR: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.subheadline)
            
            (Text("If they become unresponsive, ")
                .foregroundColor(.orange) +
            Text("start CPR")
                .foregroundColor(.blue)
                .underline() +
            Text(" immediately.")
                .foregroundColor(.orange))
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
        .onTapGesture {
            showingCPR = true
        }
    }
} 