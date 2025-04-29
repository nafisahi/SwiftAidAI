import SwiftUI
import Combine

// Data structure for food poisoning step information
struct FoodPoisoningStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for food poisoning guidance with instructions
struct FoodPoisoningView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of steps for managing food poisoning
    let steps = [
        FoodPoisoningStep(
            number: 1,
            title: "Recognize Symptoms",
            icon: "list.bullet.clipboard.fill",
            instructions: [
                "Look for these signs:",
                "• Nausea",
                "• Vomiting",
                "• Stomach cramps",
                "• Diarrhoea",
                "• Fatigue",
                "• Aches and chills",
                "• Signs of fever with high temperature"
            ],
            warningNote: "Food poisoning is usually not serious, but some cases may require medical attention.",
            imageName: nil
        ),
        FoodPoisoningStep(
            number: 2,
            title: "Immediate Actions",
            icon: "bed.double.fill",
            instructions: [
                "Advise them to lie down and rest",
                "Encourage drinking plenty of fluids:",
                "• Small sips of water if vomiting",
                "• Drink after each loose stool",
                "Avoid:",
                "• Alcohol",
                "• Caffeine",
                "• Fizzy drinks"
            ],
            warningNote: "Do not take anti-diarrhoea medicines unless specifically advised by a healthcare professional.",
            imageName: nil
        ),
        FoodPoisoningStep(
            number: 3,
            title: "When to Seek Help",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Call 999 or 112 in an emergency.",
                "Call 111 or speak to GP if:",
                "• Vomiting a lot and unable to keep fluids down",
                "• Blood in the stools",
                "• Patient is elderly or has underlying health conditions:",
                "• Diabetes",
                "• Inflammatory bowel disease",
                "• Kidney disease",
                "• Patient is pregnant",
                "• Signs of dehydration (especially in elderly, babies, or young children)"
            ],
            warningNote: "If in doubt about severity, always seek medical advice.",
            imageName: nil
        ),
        FoodPoisoningStep(
            number: 4,
            title: "Recovery & Prevention",
            icon: "hand.raised.fill",
            instructions: [
                "When appetite returns, eat light, bland, easily digested foods such as:",
                "• Bread",
                "• Rice crackers",
                "• Banana",
                "Prevent spread of infection:",
                "• Regular hand washing with soap and water",
                "• Do not use hand sanitiser"
            ],
            warningNote: "Stay off work/school for 48 hours after last episode of diarrhoea or vomiting.",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining food poisoning
                FoodPoisoningIntroCard()
                
                // Display each food poisoning step
                ForEach(steps) { step in
                    FoodPoisoningStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Food Poisoning")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
}

// Introduction card explaining what food poisoning is
struct FoodPoisoningIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is Food Poisoning?")
                .font(.title3)
                .bold()
            
            Text("Food poisoning can be caused by eating contaminated food. In most cases the food hasn't been cooked properly and is contaminated by bacteria like salmonella or E. coli. Cases are rarely serious and people usually recover within a week, but it can leave you feeling quite unwell.")
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card component for each food poisoning step with instructions and completion tracking
struct FoodPoisoningStepCard: View {
    let step: FoodPoisoningStep
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.body)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Step title and icon
                HStack {
                    Text(step.title)
                        .font(.title3)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            // Instructions section with special handling for emergency calls
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if instruction.hasPrefix("•") {
                            Text(instruction)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.leading, 28)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            CheckboxRow(
                                text: instruction,
                                isChecked: completedSteps.contains(instruction),
                                action: {
                                    if completedSteps.contains(instruction) {
                                        completedSteps.remove(instruction)
                                    } else {
                                        completedSteps.insert(instruction)
                                    }
                                }
                            )
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if instruction.contains("999") || instruction.contains("112") {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                WarningNote(text: warning)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        FoodPoisoningView()
    }
} 