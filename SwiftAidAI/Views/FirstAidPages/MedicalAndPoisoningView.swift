import SwiftUI

struct MedicalCondition: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
    let type: MedicalConditionType
}

enum MedicalConditionType {
    case diabetic
    case poisoning
    case alcoholPoisoning
    case drugOverdose
}

struct MedicalAndPoisoningView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let medicalTopics = [
        MedicalCondition(
            title: "Diabetic Emergencies",
            icon: "drop.fill",
            color: .green,
            description: "Managing high and low blood sugar emergencies",
            type: .diabetic
        ),
        
        MedicalCondition(
            title: "Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: .green,
            description: "Response to toxic substance exposure",
            type: .poisoning
        ),
        
        MedicalCondition(
            title: "Alcohol Poisoning",
            icon: "wineglass.fill",
            color: .green,
            description: "Recognizing and managing alcohol overdose",
            type: .alcoholPoisoning
        ),
        
        MedicalCondition(
            title: "Drug Overdose",
            icon: "pills.fill",
            color: .green,
            description: "Emergency response to drug overdose",
            type: .drugOverdose
        )
    ]
    
    var filteredTopics: [MedicalCondition] {
        if searchText.isEmpty {
            return medicalTopics
        }
        return medicalTopics.filter { 
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
                        
                        TextField("Search medical conditions", text: $searchText)
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
                
                // Medical Condition Cards
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: MedicalConditionDetailView(condition: topic)) {
                            MedicalConditionCard(condition: topic)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Medical & Poisoning")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MedicalConditionCard: View {
    let condition: MedicalCondition
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(condition.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: condition.icon)
                    .font(.system(size: 24))
                    .foregroundColor(condition.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(condition.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(condition.description)
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
                .stroke(condition.color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MedicalConditionDetailView: View {
    let condition: MedicalCondition
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: condition.icon)
                        .font(.system(size: 40))
                        .foregroundColor(condition.color)
                    
                    Text(condition.title)
                        .font(.title)
                        .bold()
                }
                .padding()
                
                // Content placeholder
                Text("Detailed information about \(condition.title) will be displayed here.")
                    .padding()
            }
        }
        .navigationTitle(condition.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MedicalAndPoisoningView()
    }
} 