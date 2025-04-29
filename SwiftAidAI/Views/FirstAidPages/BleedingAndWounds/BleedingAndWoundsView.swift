import SwiftUI

// Defines the structure for bleeding and wound topics with unique ID, title, icon, color, and description
struct BleedingWound: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
}

// Main view displaying a list of bleeding and wound scenarios with navigation to detailed first aid guides
struct BleedingAndWoundsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of bleeding and wound scenarios with their visual identifiers and brief descriptions
    let bleedingTopics = [
        BleedingWound(
            title: "Severe Bleeding",
            icon: "drop.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            description: "Life-threatening bleeding and hemorrhage control."
        ),
        BleedingWound(
            title: "Minor Cuts and Grazes",
            icon: "bandage.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            description: "Treatment for small wounds and abrasions."
        ),
        BleedingWound(
            title: "Nosebleeds",
            icon: "nose.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            description: "Managing and stopping nose bleeds."
        ),
        BleedingWound(
            title: "Blisters",
            icon: "bandage.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            description: "Care and treatment for skin blisters."
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Iterates through bleeding topics and creates navigation links to their respective first aid guides
                ForEach(bleedingTopics) { wound in
                    NavigationLink(destination: {
                        // Routes to the appropriate first aid guide based on the selected wound type
                        switch wound.title {
                        case "Severe Bleeding":
                            SevereBleedingGuidanceView()
                        case "Minor Cuts and Grazes":
                            CutsAndGrazesGuidanceView()
                        case "Nosebleeds":
                            NosebleedGuidanceView()
                        case "Blisters":
                            BlisterGuidanceView()
                        default:
                            BleedingWoundDetailView(wound: wound)
                        }
                    }) {
                        BleedingWoundCard(wound: wound)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Bleeding & Wounds")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
            }
        }
    }
}

// Custom card view component that displays wound information with icon, title, description, and navigation indicator
struct BleedingWoundCard: View {
    let wound: BleedingWound
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular icon container with wound-specific color and system icon
            ZStack {
                Circle()
                    .fill(wound.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: wound.icon)
                    .font(.system(size: 24))
                    .foregroundColor(wound.color)
            }
            
            // Text content section displaying the wound title and brief description
            VStack(alignment: .leading, spacing: 4) {
                Text(wound.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(wound.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
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
                .stroke(wound.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// Placeholder view for displaying detailed information about a specific wound type
struct BleedingWoundDetailView: View {
    let wound: BleedingWound
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section with icon and title
                HStack {
                    Image(systemName: wound.icon)
                        .font(.system(size: 40))
                        .foregroundColor(wound.color)
                    
                    Text(wound.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder for future implementation
                Text("Detailed information about \(wound.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(wound.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BleedingAndWoundsView()
    }
} 