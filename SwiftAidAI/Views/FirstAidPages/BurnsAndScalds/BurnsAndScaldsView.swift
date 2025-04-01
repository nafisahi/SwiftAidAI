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
    @State private var searchText = ""
    @State private var isSearching = false
    
    let burnTopics = [
        BurnInjury(
            type: .chemical,
            title: "Chemical Burns",
            description: "Burns caused by strong acids, alkalis or other chemicals",
            icon: "flask.fill",
            color: .red
        ),
        BurnInjury(
            type: .severe,
            title: "Severe Burns",
            description: "Deep or large burns requiring immediate medical attention",
            icon: "flame.fill",
            color: .red
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
    
    var filteredTopics: [BurnInjury] {
        if searchText.isEmpty {
            return burnTopics
        }
        return burnTopics.filter { 
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search burns and scalds", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                
                // Burns Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: getBurnGuidanceView(for: topic)) {
                            BurnInjuryCard(burn: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Burns & Scalds")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    func getBurnGuidanceView(for burn: BurnInjury) -> some View {
        switch burn.type {
            case .chemical:
                ChemicalBurnsGuidanceView()
            case .severe:
                SevereBurnsGuidanceView()
            case .minor:
                MinorBurnsGuidanceView()
            case .sunburn:
                SunburnGuidanceView()
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
                
                Text(burn.description)
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