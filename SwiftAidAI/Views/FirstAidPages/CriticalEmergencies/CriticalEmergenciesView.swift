import SwiftUI

// Structure for critical emergencies with ID, title, icon, color and description
struct CriticalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
}

// Main view displaying a searchable list of life-threatening emergency situations with navigation to detailed guides
struct CriticalEmergenciesView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of critical emergency scenarios with their visual identifiers and brief descriptions
    let criticalTopics = [
        CriticalEmergency(
            title: "Primary Survey (DR ABC)",
            icon: "checklist",
            color: .red,
            description: "Danger, Response, Airway, Breathing, Circulation"
        ),
        CriticalEmergency(
            title: "Unresponsive and Not Breathing (CPR)",
            icon: "heart.fill",
            color: .red,
            description: "Cardiopulmonary Resuscitation steps"
        ),
        CriticalEmergency(
            title: "Unresponsive but Breathing",
            icon: "bed.double.fill",
            color: .red,
            description: "Recovery Position guidance"
        ),
        CriticalEmergency(
            title: "Choking",
            icon: "lungs.fill",
            color: .red,
            description: "Choking response and back blows"
        ),
        CriticalEmergency(
            title: "Severe Bleeding",
            icon: "drop.fill",
            color: .red,
            description: "Managing severe blood loss"
        ),
        CriticalEmergency(
            title: "Shock",
            icon: "waveform.path.ecg",
            color: .red,
            description: "Recognizing and treating shock"
        ),
        CriticalEmergency(
            title: "Heart Attack",
            icon: "heart.slash.fill",
            color: .red,
            description: "Heart attack signs and response"
        ),
        CriticalEmergency(
            title: "Stroke",
            icon: "brain.head.profile",
            color: .red,
            description: "FAST assessment and action"
        ),
        CriticalEmergency(
            title: "Anaphylaxis",
            icon: "allergens",
            color: .red,
            description: "Severe allergic reaction response"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Iterates through filtered topics and creates navigation links to their respective detailed guidance views
                ForEach(filteredTopics) { topic in
                    NavigationLink(destination: {
                        // Routes to the appropriate detailed view based on the selected emergency topic
                        switch topic.title {
                        case "Primary Survey (DR ABC)":
                            PrimarySurveyDetailView()
                        case "Unresponsive and Not Breathing (CPR)":
                            CPRGuidanceView()
                        case "Unresponsive but Breathing":
                            RecoveryPositionView(isFromCriticalEmergencies: true)
                        case "Choking":
                            ChokingGuidanceView()
                        case "Severe Bleeding":
                            SevereBleedingGuidanceView()
                        case "Shock":
                            ShockGuidanceView()
                        case "Heart Attack":
                            HeartAttackGuidanceView()
                                .navigationTitle("Heart Attack")
                        case "Stroke":
                            StrokeGuidanceView()
                        case "Anaphylaxis":
                            AnaphylaxisGuidanceView()
                        default:
                            Text("Coming Soon")
                                .navigationTitle(topic.title)
                        }
                    }) {
                        CriticalEmergencyCard(emergency: topic)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Critical Emergencies")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search critical emergencies")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // Filters the emergency topics based on search text, matching against both title and description
    var filteredTopics: [CriticalEmergency] {
        if searchText.isEmpty {
            return criticalTopics
        } else {
            return criticalTopics.filter { topic in
                topic.title.lowercased().contains(searchText.lowercased()) ||
                topic.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

// Custom card view component that displays emergency information with icon, title, description, and navigation indicator
struct CriticalEmergencyCard: View {
    let emergency: CriticalEmergency
    
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
                
                Text(emergency.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Right-facing chevron indicating the card is tappable and leads to the firstaid guide
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
        CriticalEmergenciesView()
    }
} 
