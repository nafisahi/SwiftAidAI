import SwiftUI

// Data structure for heart attack step information
struct HeartAttackStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String
}

// Main view for heart attack guidance with step-by-step instructions
struct HeartAttackGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        HeartAttackStep(
            number: 1,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately.",
                "Tell them you suspect a heart attack.",
                "Stay on the line for further instructions."
            ],
            warningNote: "Don't delay calling - early treatment is crucial.",
            imageName: "heart-attack-1"
        ),
        HeartAttackStep(
            number: 2,
            title: "Position & Comfort",
            icon: "person.fill",
            instructions: [
                "Help them into a comfortable position on the floor.",
                "Bend their knees for support.",
                "Support their head and shoulders with cushions.",
                "Keep them calm and reassured."
            ],
            warningNote: nil,
            imageName: "heart-attack-2"
        ),
        HeartAttackStep(
            number: 3,
            title: "Medication",
            icon: "pills.fill",
            instructions: [
                "Give one 300mg aspirin tablet to chew slowly.",
                "Help them take their own angina medication if they have it."
            ],
            warningNote: "Do not give aspirin to anyone under 16 or allergic to it.",
            imageName: "heart-attack-3"
        ),
        HeartAttackStep(
            number: 4,
            title: "Monitor",
            icon: "waveform.path.ecg",
            instructions: [
                "Keep monitoring their level of response.",
                "Stay with them until help arrives.",
                "Be prepared to start CPR if they become unresponsive and stop breathing normally."
            ],
            warningNote: nil,
            imageName: "heart-attack-5"
        )
    ]
    
    // Main view body showing heart attack guidance steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining heart attack
                HeartAttackIntroCard()
                // Card showing heart attack symptoms
                HeartAttackSymptomsCard()
                
                // Display each heart attack step
                ForEach(steps) { step in
                    HeartAttackStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Heart Attack")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// Introduction card explaining what a heart attack is
struct HeartAttackIntroCard: View {
    // Main container for introduction content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a Heart Attack?")
                .font(.title2)
                .bold()
            
            Text("A heart attack happens when the supply of blood to part of the heart is suddenly blocked, usually by a blood clot. You can make a full recovery following a heart attack, but this may depend on how much of the heart is affected.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card showing heart attack symptoms and signs
struct HeartAttackSymptomsCard: View {
    // Main container for symptoms content
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Crushing pain in the centre of their chest",
                "Pain spreading to jaw and arms",
                "Breathlessness or gasping",
                "Excessive sweating",
                "Signs similar to indigestion",
                "Sudden collapse",
                "Pale skin and blue-tinted lips",
                "Rapid, weak, or irregular pulse",
                "Feeling of impending doom"
            ],
            accentColor: .red,
            warningNote: nil
        )
    }
}

// Card component for each heart attack step with instructions and completion tracking
struct HeartAttackStepCard: View {
    let step: HeartAttackStep
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
                        .fill(Color.red)
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
                        .foregroundColor(.red)
                }
            }
            
            // Step image if available
            if let uiImage = UIImage(named: step.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section containing checkboxes for each step
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        // Special handling for CPR instruction
                        if instruction.contains("start CPR") {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                    .font(.system(size: 20))
                                
                                (Text("Be prepared to ")
                                    .foregroundColor(.primary) +
                                Text("start CPR")
                                    .foregroundColor(.red)
                                    .underline() +
                                Text(" if they become unresponsive and stop breathing normally")
                                    .foregroundColor(.primary))
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showingCPR = true
                                    }
                                
                                Spacer()
                            }
                        } else {
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
                        }
                        
                        // Show emergency call buttons if instruction contains emergency numbers
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        (Text("If they become unresponsive and not breathing normally, ")
                            .foregroundColor(.orange) +
                        Text("start CPR")
                            .foregroundColor(.red)
                            .underline())
                            .font(.subheadline)
                            .onTapGesture {
                                showingCPR = true
                            }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    WarningNote(text: warning)
                }
                if hasEmergencyNumbers(warning) {
                    SharedEmergencyCallButtons()
                        .padding(.top, 4)
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
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        // Sheet presentation for CPR guidance if needed
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        HeartAttackGuidanceView()
    }
} 