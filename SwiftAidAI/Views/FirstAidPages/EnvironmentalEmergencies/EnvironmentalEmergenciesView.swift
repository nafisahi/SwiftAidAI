import SwiftUI

// Defines the structure for environmental emergency types with unique ID, title, description, icon, and color
struct EnvironmentalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: EnvironmentalEmergencyType
}

// Enum defining the different types of environmental emergencies available in the app
enum EnvironmentalEmergencyType {
    case heatstroke
    case hypothermia
}

// Main view displaying a list of environmental emergency scenarios with navigation to detailed first aid guides
struct EnvironmentalEmergenciesView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of environmental emergency scenarios with their visual identifiers and brief descriptions
    let environmentalTopics = [
        EnvironmentalEmergency(
            title: "Heatstroke",
            icon: "thermometer.sun.fill",
            color: .teal,
            description: "Managing severe heat-related illness",
            type: .heatstroke
        ),
        EnvironmentalEmergency(
            title: "Hypothermia",
            icon: "thermometer.snowflake",
            color: .teal,
            description: "Treating dangerously low body temperature",
            type: .hypothermia
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Iterates through environmental topics and creates navigation links to their respective first aid guides
                ForEach(environmentalTopics) { topic in
                    NavigationLink(destination: {
                        // Routes to the appropriate first aid guide based on the selected emergency type
                        switch topic.type {
                        case .heatstroke:
                            HeatstrokeGuidanceView()
                        case .hypothermia:
                            HypothermiaGuidanceView()
                        }
                    }) {
                        EnvironmentalEmergencyCard(emergency: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Environmental")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.teal)
                }
            }
        }
    }
}

// Custom card view component that displays environmental emergency information with icon, title, description, and navigation indicator
struct EnvironmentalEmergencyCard: View {
    let emergency: EnvironmentalEmergency
    
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

// Placeholder view for displaying detailed information about a specific environmental emergency
struct EnvironmentalEmergencyDetailView: View {
    let emergency: EnvironmentalEmergency
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section with icon and title
                HStack {
                    Image(systemName: emergency.icon)
                        .font(.system(size: 40))
                        .foregroundColor(emergency.color)
                    
                    Text(emergency.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder for future implementation
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
        EnvironmentalEmergenciesView()
    }
} 