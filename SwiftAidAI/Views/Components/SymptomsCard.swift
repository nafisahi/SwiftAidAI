import SwiftUI

struct SymptomsCard: View {
    let title: String
    let symptoms: [String]
    let accentColor: Color
    let warningNote: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with warning icon
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(accentColor)
                
                Text(title)
                    .font(.title2)
                    .bold()
            }
            
            // Symptoms list
            VStack(alignment: .leading, spacing: 12) {
                ForEach(symptoms, id: \.self) { symptom in
                    HStack(alignment: .top, spacing: 12) {
                        // Bullet point
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
            
            // Warning note if present
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