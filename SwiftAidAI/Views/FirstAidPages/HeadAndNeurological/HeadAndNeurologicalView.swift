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
    case seizure
}

struct HeadAndNeurologicalView: View {
    @Environment(\.dismiss) private var dismiss
    
    let headTopics = [
        HeadInjury(
            title: "Head Injury",
            icon: "brain.head.profile",
            color: Color(red: 0.3, green: 0.3, blue: 0.8), // Indigo color from FirstAidHomeView
            description: "Managing head trauma and monitoring symptoms",
            type: .headInjury
        ),
        
        HeadInjury(
            title: "Seizures/Epilepsy",
            icon: "waveform.path.ecg.rectangle",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            description: "Supporting someone during a seizure",
            type: .seizure
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(headTopics) { topic in
                    NavigationLink(destination: {
                        switch topic.type {
                        case .headInjury:
                            HeadInjuryGuidanceView()
                        case .seizure:
                            SeizureGuidanceView()
                        }
                    }) {
                        HeadInjuryCard(injury: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Head & Brain")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                }
            }
        }
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

struct HeadInjuryDetailView: View {
    let injury: HeadInjury
    
    var body: some View {
        Group {
            switch injury.type {
            case .headInjury:
                HeadInjuryGuidanceView()
            case .seizure:
                SeizureGuidanceView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HeadAndNeurologicalView()
    }
} 