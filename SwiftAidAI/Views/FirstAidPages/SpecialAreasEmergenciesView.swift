import SwiftUI

struct SpecialAreaEmergency: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: SpecialAreaType
}

enum SpecialAreaType {
    case eyeInjury
    case foreignObject
    case dentalInjury
}

struct SpecialAreasEmergenciesView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    // Using the brown color from FirstAidHomeView
    let specialColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    
    let specialTopics = [
        SpecialAreaEmergency(
            title: "Eye Injuries",
            icon: "eye.fill",
            color: Color(red: 0.6, green: 0.4, blue: 0.2),
            description: "Managing injuries to the eye and surrounding area",
            type: .eyeInjury
        ),
        
        SpecialAreaEmergency(
            title: "Foreign Object in Eye/Ear",
            icon: "ear.fill",
            color: Color(red: 0.6, green: 0.4, blue: 0.2),
            description: "Safe removal of foreign objects from eyes and ears",
            type: .foreignObject
        ),
        
        SpecialAreaEmergency(
            title: "Knocked-out Teeth",
            icon: "mouth.fill",
            color: Color(red: 0.6, green: 0.4, blue: 0.2),
            description: "Emergency dental care and tooth preservation",
            type: .dentalInjury
        )
    ]
    
    var filteredTopics: [SpecialAreaEmergency] {
        if searchText.isEmpty {
            return specialTopics
        }
        return specialTopics.filter { 
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
                        
                        TextField("Search eye, ear & dental emergencies", text: $searchText)
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
                
                // Special Area Emergency Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: SpecialAreaDetailView(emergency: topic)) {
                            SpecialAreaCard(emergency: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Eyes, Ears & Dental")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SpecialAreaCard: View {
    let emergency: SpecialAreaEmergency
    
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

struct SpecialAreaDetailView: View {
    let emergency: SpecialAreaEmergency
    
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
        SpecialAreasEmergenciesView()
    }
} 