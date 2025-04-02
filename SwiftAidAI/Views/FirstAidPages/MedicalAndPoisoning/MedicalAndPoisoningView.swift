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
    case foodPoisoning
    case alcoholPoisoning
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
            title: "Food Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: .orange,
            description: "Response to foodborne illness",
            type: .foodPoisoning
        ),
        
        MedicalCondition(
            title: "Alcohol Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: .purple,
            description: "Managing severe alcohol intoxication",
            type: .alcoholPoisoning
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
        switch condition.type {
        case .diabetic:
            DiabeticEmergencyView()
        case .foodPoisoning:
            FoodPoisoningView()
        case .alcoholPoisoning:
            AlcoholPoisoningView()
        }
    }
}

#Preview {
    NavigationStack {
        MedicalAndPoisoningView()
    }
} 