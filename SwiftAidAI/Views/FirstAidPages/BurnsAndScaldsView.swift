import SwiftUI

struct BurnInjury: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: BurnType
}

enum BurnType {
    case thermal
    case chemical
    case electrical
    case scald
}

struct BurnsAndScaldsView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let burnTopics = [
        // Thermal Burns
        BurnInjury(
            title: "Thermal Burns",
            icon: "flame.fill",
            color: .orange,
            description: "Burns from fire, hot surfaces, and heat sources",
            type: .thermal
        ),
        
        // Chemical Burns
        BurnInjury(
            title: "Chemical Burns",
            icon: "drop.triangle.fill",
            color: Color(red: 0.9, green: 0.5, blue: 0.0),
            description: "Burns from acids, alkalis, and other chemicals",
            type: .chemical
        ),
        
        // Electrical Burns
        BurnInjury(
            title: "Electrical Burns",
            icon: "bolt.fill",
            color: Color(red: 1.0, green: 0.6, blue: 0.0),
            description: "Burns from electrical current and lightning",
            type: .electrical
        ),
        
        // Scalds
        BurnInjury(
            title: "Scalds",
            icon: "water.waves",
            color: Color(red: 0.8, green: 0.4, blue: 0.0),
            description: "Burns from hot liquids and steam",
            type: .scald
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
                        NavigationLink(destination: BurnInjuryDetailView(burn: topic)) {
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