import SwiftUI

// Defines the structure for head injury types with unique ID, title, description, icon, and color
struct HeadInjury: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: HeadInjuryType
}


enum HeadInjuryType {
    case headInjury
    case seizure
}

// Main view displaying a list of head and neurological conditions with navigation to detailed first aid guides
struct HeadAndNeurologicalView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of head and neurological conditions with their visual identifiers and brief descriptions
    let headTopics = [
        HeadInjury(
            title: "Head Injury",
            icon: "brain.head.profile",
            color: Color(red: 0.3, green: 0.3, blue: 0.8), // Indigo color from FirstAidHomeView
            description: "Managing head trauma and monitoring symptoms",
            type: .headInjury
        ),
        
        HeadInjury(
            title: "Seizures/Epilepsy",
            icon: "waveform.path.ecg.rectangle",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            description: "Supporting someone during a seizure",
            type: .seizure
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Iterates through head topics and creates navigation links to their respective first aid guides
                ForEach(headTopics) { topic in
                    NavigationLink(destination: {
                        // Routes to the appropriate first aid guide based on the selected condition type
                        switch topic.type {
                        case .headInjury:
                            HeadInjuryGuidanceView()
                        case .seizure:
                            SeizureGuidanceView()
                        }
                    }) {
                        HeadInjuryCard(injury: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Head & Brain")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                }
            }
        }
    }
}

// Custom card view component that displays head injury information with icon, title, description, and navigation indicator
struct HeadInjuryCard: View {
    let injury: HeadInjury
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular icon container with condition-specific color and system icon
            ZStack {
                Circle()
                    .fill(injury.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: injury.icon)
                    .font(.system(size: 24))
                    .foregroundColor(injury.color)
            }
            
            // Text content section displaying the condition title and brief description
            VStack(alignment: .leading, spacing: 4) {
                Text(injury.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(injury.description)
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
                .stroke(injury.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// View for routing to the appropriate detailed guidance view based on the selected condition type
struct HeadInjuryDetailView: View {
    let injury: HeadInjury
    
    var body: some View {
        Group {
            switch injury.type {
            case .headInjury:
                HeadInjuryGuidanceView()
            case .seizure:
                SeizureGuidanceView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HeadAndNeurologicalView()
    }
} 