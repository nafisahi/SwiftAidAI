import SwiftUI

struct BreathingIssue: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: BreathingIssueType
}

enum BreathingIssueType {
    case asthma
    case hyperventilation
}

struct BreathingIssuesView: View {
    @Environment(\.dismiss) private var dismiss
    
    let breathingTopics = [
        // Asthma Attacks
        BreathingIssue(
            title: "Asthma Attacks",
            icon: "lungs.fill",
            color: .blue,
            description: "Managing acute asthma and using inhalers",
            type: .asthma
        ),
        
        // Hyperventilation
        BreathingIssue(
            title: "Hyperventilation",
            icon: "wind",
            color: Color(red: 0.0, green: 0.5, blue: 1.0),
            description: "Breathing control and panic management",
            type: .hyperventilation
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(breathingTopics) { topic in
                    NavigationLink(destination: {
                        switch topic.type {
                        case .asthma:
                            AsthmaGuidanceView()
                        case .hyperventilation:
                            HyperventilationGuidanceView()
                        }
                    }) {
                        BreathingIssueCard(issue: topic)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Breathing Issues")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct BreathingIssueCard: View {
    let issue: BreathingIssue
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(issue.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: issue.icon)
                    .font(.system(size: 24))
                    .foregroundColor(issue.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(issue.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(issue.description)
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
                .stroke(issue.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BreathingIssueDetailView: View {
    let issue: BreathingIssue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: issue.icon)
                        .font(.system(size: 40))
                        .foregroundColor(issue.color)
                    
                    Text(issue.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
                Text("Detailed information about \(issue.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(issue.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BreathingIssuesView()
    }
} 