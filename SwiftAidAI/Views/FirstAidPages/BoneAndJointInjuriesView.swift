import SwiftUI

struct BoneInjury: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: BoneInjuryType
}

enum BoneInjuryType {
    case fracture
    case sprain
    case dislocation
    case spinal
}

struct BoneAndJointInjuriesView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let boneTopics = [
        // Broken Bones
        BoneInjury(
            title: "Broken Bones",
            icon: "cross.case.fill",
            color: .purple,
            description: "Managing fractures and broken bones safely",
            type: .fracture
        ),
        
        // Sprains and Strains
        BoneInjury(
            title: "Sprains and Strains",
            icon: "figure.walk",
            color: Color(red: 0.6, green: 0.2, blue: 0.8),
            description: "Soft tissue and muscle injuries",
            type: .sprain
        ),
        
        // Dislocated Joints
        BoneInjury(
            title: "Dislocated Joints",
            icon: "figure.arms.open",
            color: Color(red: 0.5, green: 0.1, blue: 0.7),
            description: "Joint displacement and management",
            type: .dislocation
        ),
        
        // Spinal Injuries
        BoneInjury(
            title: "Spinal Injuries",
            icon: "figure.seated.side",
            color: Color(red: 0.4, green: 0.0, blue: 0.6),
            description: "Suspected spinal cord injuries and immobilization",
            type: .spinal
        )
    ]
    
    var filteredTopics: [BoneInjury] {
        if searchText.isEmpty {
            return boneTopics
        }
        return boneTopics.filter { 
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
                        
                        TextField("Search bone and joint injuries", text: $searchText)
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
                
                // Injury Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: BoneInjuryDetailView(injury: topic)) {
                            BoneInjuryCard(injury: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Bone & Joint Injuries")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BoneInjuryCard: View {
    let injury: BoneInjury
    
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

struct BoneInjuryDetailView: View {
    let injury: BoneInjury
    
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
        BoneAndJointInjuriesView()
    }
} 