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
    @Environment(\.dismiss) private var dismiss
    
    let boneTopics = [
        // Broken Bones
        BoneInjury(
            title: "Broken Bones (Fractures)",
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
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(boneTopics) { topic in
                    NavigationLink(destination: {
                        switch topic.type {
                        case .fracture:
                            BrokenBonesGuidanceView()
                        case .sprain:
                            SprainsGuidanceView()
                        case .dislocation:
                            Text("Dislocation guidance coming soon")
                                .padding()
                        case .spinal:
                            Text("Spinal injury guidance coming soon")
                                .padding()
                        }
                    }) {
                        BoneInjuryCard(injury: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Bone & Joint Injuries")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.purple)
                }
            }
        }
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
                    .multilineTextAlignment(.leading)
                
                Text(injury.description)
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