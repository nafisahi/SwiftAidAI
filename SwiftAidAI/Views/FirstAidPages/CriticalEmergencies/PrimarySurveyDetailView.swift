import SwiftUI

// Model for each step in the primary survey process
struct PrimarySurveyStep: Identifiable {
    let id = UUID()
    let number: Int
    let letter: String
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String
}

// Main view for displaying the primary survey steps
struct PrimarySurveyDetailView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Define all steps in the primary survey 
    let steps = [
        PrimarySurveyStep(
            number: 1,
            letter: "D",
            title: "Danger",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Before approaching the casualty, always make sure the area is safe.",
                "Check for any hazards that could put you or the casualty at risk."
            ],
            warningNote: nil,
            imageName: "danger 1"
        ),
        PrimarySurveyStep(
            number: 2,
            letter: "R",
            title: "Response",
            icon: "person.wave.2.fill",
            instructions: [
                "As you approach, introduce yourself clearly.",
                "Kneel next to their chest and gently shake their shoulders.",
                "Ask clearly: 'Are you OK?', 'Can you open your eyes?'",
                "If they open their eyes or give another gesture, they are responsive.",
                "If they do not respond in any way, they are unresponsive.",
                "Check for catastrophic bleeding (massive amounts of blood pouring, gushing, or spurting).",
                "If catastrophic bleeding is present, apply direct pressure immediately and call 999 or 112."
            ],
            warningNote: "Catastrophic bleeding must be treated before moving on to the airway",
            imageName: "response 2"
        ),
        PrimarySurveyStep(
            number: 3,
            letter: "A",
            title: "Airway",
            icon: "wind",
            instructions: [
                "Check that the airway is open and clear.",
                "Place one hand on the forehead to tilt the head back.",
                "Use two fingers from the other hand to lift the chin."
            ],
            warningNote: nil,
            imageName: "airway 3"
        ),
        PrimarySurveyStep(
            number: 4,
            letter: "B",
            title: "Breathing",
            icon: "lungs.fill",
            instructions: [
                "Keep the airway held open.",
                "Place your ear above their mouth and look down at their chest.",
                "Listen for sounds of breathing and feel for breath on your cheek.",
                "Watch to see if their chest moves.",
                "Do this for no more than 10 seconds."
            ],
            warningNote: "During cardiac arrest, about half of casualties will show 'agonal gasping' (slow, noisy gasps) - this is not normal breathing and indicates cardiac arrest",
            imageName: "breathing 4"
        ),
        PrimarySurveyStep(
            number: 5,
            letter: "C",
            title: "Circulation",
            icon: "heart.fill",
            instructions: [
                "If severe bleeding is present, apply direct pressure to the wound and call 999 or 112.",
                "If unresponsive but breathing normally with no bleeding, place in recovery position and call 999 or 112."
            ],
            warningNote: nil,
            imageName: "circulation 5"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display introduction card
                IntroductionCard()
                
                // Display each step in the survey
                ForEach(steps) { step in
                    PrimarySurveyStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Display attribution footer
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Primary Survey (DR ABC)")
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

// Card showing introduction to the primary survey
struct IntroductionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Follow these steps carefully")
                .font(.title2)
                .bold()
            
            Text("The primary survey (DR ABC) helps you quickly identify and treat life-threatening conditions in order of priority.")
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

// Card displaying a single step in the primary survey
struct PrimarySurveyStepCard: View {
    let step: PrimarySurveyStep
    @Binding var completedSteps: Set<String>
    @State private var showingSevereBurns = false
    @State private var showingRecoveryPosition = false
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Step header with number, letter, title and icon
            HStack(spacing: 16) {
                // Step Number Circle
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Title and Icon
                HStack {
                    Text("\(step.letter) - \(step.title)")
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            
            // Display step image if available
            if let uiImage = UIImage(named: step.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // List of instructions for this primary survey step, with handling for severe bleeding and recovery position
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if step.number == 5 {
                            if instruction.contains("severe bleeding") {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                        .font(.system(size: 20))
                                    
                                    (Text("If ")
                                        .foregroundColor(.primary) +
                                    Text("severe bleeding")
                                        .foregroundColor(.red)
                                        .underline() +
                                    Text(" is present, apply direct pressure to the wound and call 999 or 112.")
                                        .foregroundColor(.primary))
                                        .font(.subheadline)
                                        .onTapGesture {
                                            showingSevereBurns = true
                                        }
                                    
                                    Spacer()
                                }
                            } else if instruction.contains("recovery position") {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                        .font(.system(size: 20))
                                    
                                    (Text("If unresponsive but breathing normally with no bleeding, place in ")
                                        .foregroundColor(.primary) +
                                    Text("recovery position")
                                        .foregroundColor(.red)
                                        .underline() +
                                    Text(" and call 999 or 112.")
                                        .foregroundColor(.primary))
                                        .font(.subheadline)
                                        .onTapGesture {
                                            showingRecoveryPosition = true
                                        }
                                    
                                    Spacer()
                                }
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
                            }
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
                            // Only show emergency call buttons for non step 5 instructions
                            if hasEmergencyNumbers(instruction) {
                                SharedEmergencyCallButtons()
                                    .padding(.leading, 28)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
            // Show emergency call buttons only once for step 5, after both checkboxes
            if step.number == 5 {
                SharedEmergencyCallButtons()
                    .padding(.top, 4)
            }
            
            // Display warning note if present
            if let warning = step.warningNote {
                WarningNote(text: warning)
                if hasEmergencyNumbers(warning) {
                    SharedEmergencyCallButtons()
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingSevereBurns) {
            SevereBurnsGuidanceView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingRecoveryPosition) {
            RecoveryPositionView()
                .presentationDragIndicator(.visible)
        }
    }
}

// Card showing emergency actions to take
struct EmergencyActionsCard: View {
    @State private var showingCPR = false
    @State private var showingRecoveryPosition = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Steps")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Button to show CPR guidance
                Button(action: { showingCPR = true }) {
                    ActionItem(
                        icon: "xmark.circle.fill",
                        color: .red,
                        text: "If casualty is not breathing, immediately start CPR.",
                        isLink: true
                    )
                }
                
                // Button to show recovery position guidance
                Button(action: { showingRecoveryPosition = true }) {
                    ActionItem(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        text: "If casualty is breathing, place in Recovery Position",
                        isLink: true
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .padding(.horizontal)
        // Present CPR guidance sheet
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
                .presentationDragIndicator(.visible)
        }
        // Present recovery position guidance sheet
        .sheet(isPresented: $showingRecoveryPosition) {
            RecoveryPositionView()
                .presentationDragIndicator(.visible)
        }
    }
}

// View for displaying an action item with icon and text
struct ActionItem: View {
    let icon: String
    let color: Color
    let text: String
    var isLink: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .foregroundColor(isLink ? .red : .primary)
                .underline(isLink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Footer showing source attribution
struct AttributionFooter: View {
    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.horizontal)
            
            Text("Information and images sourced from")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Link(destination: URL(string: "https://www.sja.org.uk")!) {
                HStack(spacing: 4) {
                    Text("St John Ambulance")
                        .font(.footnote)
                        .foregroundColor(.teal)
                    
                    Image(systemName: "link")
                        .font(.footnote)
                        .foregroundColor(.teal)
                }
            }
            
            Text("© St John Ambulance")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        PrimarySurveyDetailView()
    }
} 
