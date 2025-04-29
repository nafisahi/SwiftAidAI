import SwiftUI

// Defines the structure for medical emergency types with unique ID, title, description, icon, and color
struct MedicalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: MedicalEmergencyType
}

// Enum defining the different types of medical emergencies for navigation routing
enum MedicalEmergencyType {
    case diabetic
    case foodPoisoning
    case alcoholPoisoning
}

// Main view displaying a list of medical and poisoning scenarios with navigation to detailed first aid guides
struct MedicalAndPoisoningView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of medical emergency scenarios with their visual identifiers and brief descriptions
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
                // Iterates through medical topics and creates navigation links to their respective first aid guides
                ForEach(medicalTopics) { topic in
                    NavigationLink(destination: {
                        // Routes to the appropriate first aid guide based on the selected emergency type
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

// Custom card view component that displays medical emergency information with icon, title, description, and navigation indicator
struct MedicalEmergencyCard: View {
    let emergency: MedicalEmergency
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular icon container with emergency-specific color and system icon
            ZStack {
                Circle()
                    .fill(emergency.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: emergency.icon)
                    .font(.system(size: 24))
                    .foregroundColor(emergency.color)
            }
            
            // Text content section displaying the emergency title and brief description
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
            
            // Right-facing chevron indicating the card is tappable and leads to the first aid guide
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