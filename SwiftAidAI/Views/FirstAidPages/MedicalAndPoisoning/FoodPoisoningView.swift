import SwiftUI
import Combine

struct FoodPoisoningStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct FoodPoisoningView: View {
    @State private var completedSteps: Set<String> = []
    
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
                "   • Small sips of water if vomiting",
                "   • Drink after each loose stool",
                "Avoid:",
                "   • Alcohol",
                "   • Caffeine",
                "   • Fizzy drinks"
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
                "   • Diabetes",
                "   • Inflammatory bowel disease",
                "   • Kidney disease",
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
                "When appetite returns:",
                "• Eat light, bland, easily digested foods:",
                "   • Bread",
                "   • Rice crackers",
                "   • Banana",
                "Prevent spread of infection:",
                "• Regular hand washing with soap and water",
                "• Do not use hand sanitiser",
               
               
            ],
            warningNote: "Stay off work/school for 48 hours after last episode of diarrhoea or vomiting",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FoodPoisoningIntroCard()
                
                ForEach(steps) { step in
                    FoodPoisoningStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Food Poisoning")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FoodPoisoningIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is Food Poisoning?")
                .font(.title2)
                .bold()
            
            Text("Food poisoning can be caused by eating contaminated food. In most cases the food hasn't been cooked properly and is contaminated by bacteria like salmonella or E. coli. Cases are rarely serious and people usually recover within a week, but it can leave you feeling quite unwell.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct FoodPoisoningStepCard: View {
    let step: FoodPoisoningStep
    @Binding var completedSteps: Set<String>
    
    private func shouldHaveCheckbox(_ text: String) -> Bool {
        let checkboxItems = [
            "Look for these signs:",
            "Advise them to lie down and rest",
            "Encourage drinking plenty of fluids:",
            "Avoid:",
            "Call 999 or 112 in an emergency.",
            "Call 111 or speak to GP if:",
            "When appetite returns:",
            "Prevent spread of infection:"
        ]
        return checkboxItems.contains(text)
    }
    
    private func shouldShowEmergencyButtons(_ text: String) -> Bool {
        // Only show emergency buttons for 999/112 calls, not for 111/GP
        return text.contains("999") || text.contains("112")
    }
    
    // Check if this step has emergency call instructions
    private var hasEmergencyCallInstructions: Bool {
        for instruction in step.instructions {
            if instruction.contains("999") || instruction.contains("112") || instruction.contains("111") {
                return true
            }
        }
        return false
    }
    
    // Check if warning note contains emergency numbers
    private var warningHasEmergencyNumbers: Bool {
        if let warning = step.warningNote {
            return warning.contains("999") || warning.contains("112") || warning.contains("111")
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            
            // Add the image if present
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if shouldHaveCheckbox(instruction) {
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
                        } else {
                            Text(instruction)
                                .font(.body)
                                .foregroundColor(instruction.hasSuffix(":") ? .primary : .secondary)
                                .padding(.leading, getPaddingForInstruction(instruction))
                                .padding(.vertical, 2)
                        }
                        
                        if shouldShowEmergencyButtons(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                WarningNote(text: warning)
                    .padding(.top, 4)
                
                if warningHasEmergencyNumbers {
                    SharedEmergencyCallButtons()
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func getPaddingForInstruction(_ instruction: String) -> CGFloat {
        if instruction.hasPrefix("   •") {
            return 48
        } else if instruction.hasPrefix("•") {
            return 24
        } else {
            return 8
        }
    }
}

#Preview {
    NavigationStack {
        FoodPoisoningView()
    }
} 