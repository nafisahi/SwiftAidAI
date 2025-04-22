import SwiftUI

struct EnvironmentalEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: EnvironmentalEmergencyType
}

enum EnvironmentalEmergencyType {
    case heatstroke
    case hypothermia
}

struct EnvironmentalEmergenciesView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                ForEach(environmentalTopics) { topic in
                    NavigationLink(destination: {
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

struct EnvironmentalEmergencyCard: View {
    let emergency: EnvironmentalEmergency
    
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

struct EnvironmentalEmergencyDetailView: View {
    let emergency: EnvironmentalEmergency
    
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
        EnvironmentalEmergenciesView()
    }
} 