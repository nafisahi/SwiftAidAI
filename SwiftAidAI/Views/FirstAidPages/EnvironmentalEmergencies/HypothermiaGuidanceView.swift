import SwiftUI

// Data structure for hypothermia step information
struct HypothermiaStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for hypothermia guidance with instructions
struct HypothermiaGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of steps for managing hypothermia
    let steps = [
        HypothermiaStep(
            number: 1,
            title: "Move to Shelter",
            icon: "house.fill",
            instructions: [
                "Move them indoors if possible.",
                "If outdoors, find a sheltered place.",
                "Shield them from wind.",
                "Protect them from cold ground using insulating materials."
            ],
            warningNote: nil,
            imageName: nil
        ),
        HypothermiaStep(
            number: 2,
            title: "Manage Clothing",
            icon: "tshirt.fill",
            instructions: [
                "Remove any wet clothing.",
                "Replace with dry clothing or blankets.",
                "Cover their head.",
                "Wrap in foil survival blanket if available."
            ],
            warningNote: "Do not give away your own clothes - you must stay warm too.",
            imageName: nil
        ),
        HypothermiaStep(
            number: 3,
            title: "Call for Help",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help.",
                "Stay with the casualty.",
                "If in remote area, send two people for help together."
            ],
            warningNote: "Never leave the casualty alone.",
            imageName: nil
        ),
        HypothermiaStep(
            number: 4,
            title: "Warm Gradually",
            icon: "thermometer.medium",
            instructions: [
                "If indoors, warm room to about 25°C.",
                "Cover with layers of blankets.",
                "If alert, give warm drinks and high-energy food.",
                "Monitor breathing and response level."
            ],
            warningNote: "Do not apply direct heat (hot water bottles/fires) - risk of burns. Do not give alcohol.",
            imageName: nil
        ),
        HypothermiaStep(
            number: 5,
            title: "Monitor Condition",
            icon: "heart.text.square.fill",
            instructions: [
                "Check breathing regularly.",
                "Monitor level of response.",
                "Watch for signs of improvement.",
                "Be prepared to start CPR if they become unresponsive."
            ],
            warningNote: "If they become unresponsive, start CPR.",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining hypothermia
                HypothermiaIntroductionCard()
                
                // Display each hypothermia step
                ForEach(steps) { step in
                    HypothermiaStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Hypothermia")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.teal)
                        Text("Back")
                            .foregroundColor(.teal)
                    }
                }
            }
        }
    }
}

// Introduction card explaining what hypothermia is and its symptoms
struct HypothermiaIntroductionCard: View {
    // Main container for introduction content
    var body: some View {
        VStack(spacing: 16) {
            // What is Hypothermia explanation
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Hypothermia?")
                    .font(.title2)
                    .bold()
                
                Text("Hypothermia occurs when body temperature drops below 35°C (95°F). Normal body temperature is around 37°C (98.6°F). This condition can become life-threatening quickly and requires immediate treatment.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.teal.opacity(0.1))
            )
            
            // Symptoms card showing signs of hypothermia
            HypothermiaSymptomsCard()
        }
        .padding(.horizontal)
    }
}

// Card showing hypothermia symptoms and signs
struct HypothermiaSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Shivering, cold and pale with dry skin",
                "Unusually tired and confused",
                "Irrational behaviour",
                "Reduced level of response",
                "Slow and shallow breathing",
                "Slow and weakening pulse"
            ],
            accentColor: .teal,
            warningNote: "Hypothermia is a medical emergency - call 999/112"
        )
    }
}

// Card component for each hypothermia step with instructions and completion tracking
struct HypothermiaStepCard: View {
    let step: HypothermiaStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    // Main container for step content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator
                ZStack {
                    Circle()
                        .fill(Color.teal)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Step title and icon
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.teal)
                }
            }
            
            // Step image if available
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section with checkboxes and emergency buttons
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        // Standard checkbox row for instructions
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
                        
                        // Show emergency call buttons if instruction contains emergency numbers
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
                
                // Warning note section with emergency call buttons if needed
                if let warning = step.warningNote {
                    if warning.contains("CPR") {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.subheadline)
                            
                            (Text("If they become unresponsive, ")
                                .foregroundColor(.orange) +
                            Text("start CPR")
                                .foregroundColor(.teal)
                                .underline())
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 4)
                        .onTapGesture {
                            showingCPR = true
                        }
                    } else {
                        WarningNote(text: warning)
                    }
                    if hasEmergencyNumbers(warning) {
                        SharedEmergencyCallButtons()
                            .padding(.top, 4)
                    }
                }
            }
        }
        // Card styling with background, shadow and border
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        // Sheet presentation for CPR guidance if needed
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
}

#Preview {
    NavigationStack {
        HypothermiaGuidanceView()
    }
} 