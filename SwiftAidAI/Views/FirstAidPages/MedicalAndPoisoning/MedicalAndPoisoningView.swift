import SwiftUI

struct MedicalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: MedicalEmergencyType
}

enum MedicalEmergencyType {
    case diabetic
    case foodPoisoning
    case alcoholPoisoning
}

struct MedicalAndPoisoningView: View {
    @Environment(\.dismiss) private var dismiss
    
    let medicalTopics = [
        MedicalEmergency(
            title: "Diabetic Emergencies",
            icon: "cross.case.fill",
            color: .green,
            description: "Managing high and low blood sugar emergencies",
            type: .diabetic
        ),
        MedicalEmergency(
            title: "Food Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: .green,
            description: "Treating food poisoning symptoms",
            type: .foodPoisoning
        ),
        MedicalEmergency(
            title: "Alcohol Poisoning",
            icon: "wineglass",
            color: .green,
            description: "Recognizing and managing alcohol poisoning",
            type: .alcoholPoisoning
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(medicalTopics) { topic in
                    NavigationLink(destination: {
                        switch topic.type {
                        case .diabetic:
                            DiabeticEmergencyView()
                        case .foodPoisoning:
                            FoodPoisoningView()
                        case .alcoholPoisoning:
                            AlcoholPoisoningView()
                        }
                    }) {
                        MedicalEmergencyCard(emergency: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Medical & Poisoning")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
}

struct MedicalEmergencyCard: View {
    let emergency: MedicalEmergency
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(emergency.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: emergency.icon)
                    .font(.system(size: 24))
                    .foregroundColor(emergency.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(emergency.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(emergency.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(emergency.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        MedicalAndPoisoningView()
    }
} 