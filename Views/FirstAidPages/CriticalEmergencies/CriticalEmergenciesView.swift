import SwiftUI

struct CriticalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
}

struct CriticalEmergenciesView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let criticalTopics = [
        CriticalEmergency(
            title: "Primary Survey (DR ABC)",
            icon: "checklist",
            color: .blue,
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
            color: .orange,
            description: "Recovery Position guidance"
        ),
        CriticalEmergency(
            title: "Choking",
            icon: "lungs.fill",
            color: .purple,
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
            color: .pink,
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
            color: .purple,
            description: "FAST assessment and action"
        ),
        CriticalEmergency(
            title: "Anaphylaxis",
            icon: "allergens",
            color: .orange,
            description: "Severe allergic reaction response"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(filteredTopics) { topic in
                    NavigationLink(destination: {
                        switch topic.title {
                        case "Primary Survey (DR ABC)":
                            PrimarySurveyDetailView()
                        case "Unresponsive and Not Breathing (CPR)":
                            CPRGuidanceView()
                        case "Unresponsive but Breathing":
                            RecoveryPositionView()
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
    }
    
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

struct CriticalEmergencyCard: View {
    let emergency: CriticalEmergency
    
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
                
                Text(emergency.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
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

// Placeholder for the detail view
struct CriticalEmergencyDetailView: View {
    let emergency: CriticalEmergency
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: emergency.icon)
                        .font(.system(size: 40))
                        .foregroundColor(emergency.color)
                    
                    Text(emergency.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
                Text("Detailed information about \(emergency.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(emergency.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CriticalEmergenciesView()
    }
} 
