import SwiftUI

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

struct BurnsAndScaldsView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                ForEach(burnTopics) { topic in
                    NavigationLink(destination: {
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

struct BurnInjuryCard: View {
    let burn: BurnInjury
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(burn.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: burn.icon)
                    .font(.system(size: 24))
                    .foregroundColor(burn.color)
            }
            
            // Content
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
                .stroke(burn.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BurnInjuryDetailView: View {
    let burn: BurnInjury
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: burn.icon)
                        .font(.system(size: 40))
                        .foregroundColor(burn.color)
                    
                    Text(burn.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
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


