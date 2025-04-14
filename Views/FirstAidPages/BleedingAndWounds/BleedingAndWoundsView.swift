import SwiftUI

struct BleedingWound: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
}

struct BleedingAndWoundsView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let bleedingTopics = [
        BleedingWound(
            title: "Severe Bleeding",
            icon: "drop.fill",
            color: .red,
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
            color: Color(red: 0.9, green: 0.3, blue: 0.3),
            description: "Managing and stopping nose bleeds."
        ),
        BleedingWound(
            title: "Blisters",
            icon: "bandage.fill",
            color: Color(red: 0.7, green: 0.1, blue: 0.1),
            description: "Care and treatment for skin blisters."
        )
    ]
    
    var filteredTopics: [BleedingWound] {
        if searchText.isEmpty {
            return bleedingTopics
        }
        return bleedingTopics.filter { 
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(filteredTopics) { wound in
                    NavigationLink(destination: {
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
        .searchable(text: $searchText, prompt: "Search bleeding & wounds")
    }
}

struct BleedingWoundCard: View {
    let wound: BleedingWound
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(wound.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: wound.icon)
                    .font(.system(size: 24))
                    .foregroundColor(wound.color)
            }
            
            // Content
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
                .stroke(wound.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BleedingWoundDetailView: View {
    let wound: BleedingWound
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: wound.icon)
                        .font(.system(size: 40))
                        .foregroundColor(wound.color)
                    
                    Text(wound.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
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