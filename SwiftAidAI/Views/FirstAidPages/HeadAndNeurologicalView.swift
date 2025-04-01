import SwiftUI

struct HeadInjury: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: HeadInjuryType
}

enum HeadInjuryType {
    case headInjury
    case concussion
    case seizure
}

struct HeadAndNeurologicalView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let headTopics = [
        HeadInjury(
            title: "Head Injury",
            icon: "brain.head.profile",
            color: Color(red: 0.3, green: 0.3, blue: 0.8), // Indigo color from FirstAidHomeView
            description: "Managing head trauma and monitoring symptoms",
            type: .headInjury
        ),
        
        HeadInjury(
            title: "Concussion",
            icon: "sparkles.square.filled.on.square",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            description: "Recognition and immediate care for concussions",
            type: .concussion
        ),
        
        HeadInjury(
            title: "Seizures/Epilepsy",
            icon: "waveform.path.ecg.rectangle",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            description: "Supporting someone during a seizure",
            type: .seizure
        )
    ]
    
    var filteredTopics: [HeadInjury] {
        if searchText.isEmpty {
            return headTopics
        }
        return headTopics.filter { 
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
                        
                        TextField("Search head injuries", text: $searchText)
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
                
                // Head Injury Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: HeadInjuryDetailView(injury: topic)) {
                            HeadInjuryCard(injury: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Head & Neurological")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HeadInjuryCard: View {
    let injury: HeadInjury
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(injury.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: injury.icon)
                    .font(.system(size: 24))
                    .foregroundColor(injury.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(injury.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(injury.description)
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
                .stroke(injury.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct HeadInjuryDetailView: View {
    let injury: HeadInjury
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: injury.icon)
                        .font(.system(size: 40))
                        .foregroundColor(injury.color)
                    
                    Text(injury.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
                Text("Detailed information about \(injury.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(injury.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HeadAndNeurologicalView()
    }
} 