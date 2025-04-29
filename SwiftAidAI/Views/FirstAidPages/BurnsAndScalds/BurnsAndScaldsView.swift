import SwiftUI

// Defines the structure for burn injury types with unique ID, title, description, icon, and color
struct BurnInjury: Identifiable {
    let id = UUID()
    let type: BurnType
    let title: String
    let description: String
    let icon: String
    let color: Color
}


enum BurnType {
    case chemical
    case severe
    case minor
    case sunburn
}

// Main view displaying a list of burn and scald scenarios with navigation to detailed first aid guides
struct BurnsAndScaldsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of burn and scald scenarios with their visual identifiers and brief descriptions
    let burnTopics = [
        BurnInjury(
            type: .chemical,
            title: "Chemical Burns",
            description: "Burns caused by strong acids, alkalis or other chemicals",
            icon: "flask.fill",
            color: .orange
        ),
        BurnInjury(
            type: .severe,
            title: "Severe Burns",
            description: "Deep or large burns requiring immediate medical attention",
            icon: "flame.fill",
            color: .orange
        ),
        BurnInjury(
            type: .minor,
            title: "Minor Burns",
            description: "Small burns and scalds that can be treated at home",
            icon: "bandage.fill",
            color: .orange
        ),
        BurnInjury(
            type: .sunburn,
            title: "Sunburn",
            description: "Skin damage caused by exposure to UV rays",
            icon: "sun.max.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Iterates through burn topics and creates navigation links to their respective first aid guides
                ForEach(burnTopics) { topic in
                    NavigationLink(destination: {
                        // Routes to the appropriate first aid guide based on the selected burn type
                        switch topic.type {
                        case .chemical:
                            ChemicalBurnsGuidanceView()
                        case .severe:
                            SevereBurnsGuidanceView()
                        case .minor:
                            MinorBurnsGuidanceView()
                        case .sunburn:
                            SunburnGuidanceView()
                        }
                    }) {
                        BurnInjuryCard(burn: topic)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Burns & Scalds")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// Custom card view component that displays burn information with icon, title, description, and navigation indicator
struct BurnInjuryCard: View {
    let burn: BurnInjury
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular icon container with burn-specific color and system icon
            ZStack {
                Circle()
                    .fill(burn.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: burn.icon)
                    .font(.system(size: 24))
                    .foregroundColor(burn.color)
            }
            
            // Text content section displaying the burn title and brief description
            VStack(alignment: .leading, spacing: 4) {
                Text(burn.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(burn.description)
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
                .stroke(burn.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// Placeholder view for displaying detailed information about a specific burn type
struct BurnInjuryDetailView: View {
    let burn: BurnInjury
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section with icon and title
                HStack {
                    Image(systemName: burn.icon)
                        .font(.system(size: 40))
                        .foregroundColor(burn.color)
                    
                    Text(burn.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder for future implementation
                Text("Detailed information about \(burn.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(burn.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BurnsAndScaldsView()
    }
} 


