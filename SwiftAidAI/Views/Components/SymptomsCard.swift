import SwiftUI

// A card component for displaying symptoms of a medical condition
struct SymptomsCard: View {
    // Card properties
    let title: String
    let symptoms: [String]
    let accentColor: Color
    let warningNote: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title section with warning icon
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(accentColor)
                
                Text(title)
                    .font(.title2)
                    .bold()
            }
            
            // List of symptoms with bullet points
            VStack(alignment: .leading, spacing: 12) {
                ForEach(symptoms, id: \.self) { symptom in
                    HStack(alignment: .top, spacing: 12) {
                        // Custom bullet point
                        Circle()
                            .fill(accentColor)
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(symptom)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Optional warning note at the bottom
            if let warning = warningNote {
                Text(warning)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(accentColor.opacity(0.1))
        )
        .padding(.horizontal)
    }
} 