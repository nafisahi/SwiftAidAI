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
    case heatExhaustion
    case hypothermia
    case frostbite
    case animalBite
    case insectBite
    case tickRemoval
}

struct EnvironmentalEmergenciesView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let environmentalTopics = [
        // Heat-related
        EnvironmentalEmergency(
            title: "Heatstroke",
            icon: "thermometer.sun.fill",
            color: .teal,
            description: "Life-threatening high body temperature",
            type: .heatstroke
        ),
        
        EnvironmentalEmergency(
            title: "Heat Exhaustion",
            icon: "sun.max.fill",
            color: .teal,
            description: "Overheating and dehydration symptoms",
            type: .heatExhaustion
        ),
        
        // Cold-related
        EnvironmentalEmergency(
            title: "Hypothermia",
            icon: "thermometer.snowflake",
            color: .teal,
            description: "Dangerous lowering of body temperature",
            type: .hypothermia
        ),
        
        EnvironmentalEmergency(
            title: "Frostbite",
            icon: "snow",
            color: .teal,
            description: "Freezing damage to skin and tissues",
            type: .frostbite
        ),
        
        // Animal-related
        EnvironmentalEmergency(
            title: "Animal Bites",
            icon: "pawprint.fill",
            color: .teal,
            description: "Treatment for domestic and wild animal bites",
            type: .animalBite
        ),
        
        EnvironmentalEmergency(
            title: "Insect Stings and Bites",
            icon: "ant.fill",
            color: .teal,
            description: "Managing insect bite reactions",
            type: .insectBite
        ),
        
        EnvironmentalEmergency(
            title: "Tick Removal",
            icon: "cross.circle.fill",
            color: .teal,
            description: "Safe removal and bite assessment",
            type: .tickRemoval
        )
    ]
    
    var filteredTopics: [EnvironmentalEmergency] {
        if searchText.isEmpty {
            return environmentalTopics
        }
        return environmentalTopics.filter { 
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
                        
                        TextField("Search environmental emergencies", text: $searchText)
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
                
                // Environmental Emergency Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: EnvironmentalEmergencyDetailView(emergency: topic)) {
                            EnvironmentalEmergencyCard(emergency: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Environmental")
        .navigationBarTitleDisplayMode(.large)
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