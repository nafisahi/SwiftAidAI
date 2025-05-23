import SwiftUI

// Data structure for stroke step information
struct StrokeStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for stroke guidance with instructions
struct StrokeGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        StrokeStep(
            number: 1,
            title: "Face (F)",
            icon: "face.smiling",
            instructions: [
                "Look at their face for signs of weakness.",
                "Check if their mouth or eyes are droopy.",
                "Ask them to smile - check if it's uneven."
            ],
            warningNote: nil,
            imageName: "face"
        ),
        StrokeStep(
            number: 2,
            title: "Arms (A)",
            icon: "figure.arms.open",
            instructions: [
                "Ask them to raise both arms.",
                "Check if they can keep both arms raised.",
                "Note if one arm drifts downward."
            ],
            warningNote: nil,
            imageName: "arm"
        ),
        StrokeStep(
            number: 3,
            title: "Speech (S)",
            icon: "text.bubble.fill",
            instructions: [
                "Ask them simple questions (e.g., 'What is your name?').",
                "Check if they can speak clearly.",
                "Note if they have trouble understanding you."
            ],
            warningNote: nil,
            imageName: "speech"
        ),
        StrokeStep(
            number: 4,
            title: "Time to Call (T)",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately.",
                "Tell them you suspect a stroke.",
                "Explain the FAST symptoms you observed."
            ],
            warningNote: "Every minute counts - don't delay calling for help.",
            imageName: "time"
        ),
        StrokeStep(
            number: 5,
            title: "Care While Waiting",
            icon: "heart.circle.fill",
            instructions: [
                "Keep them comfortable and supported.",
                "Provide reassurance.",
                "Do not give them food or drink.",
                "Monitor their level of response."
            ],
            warningNote: "If they become unresponsive, prepare to start CPR.",
            imageName: nil
        )
    ]
    
    // Main view body showing stroke guidance steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining stroke
                StrokeIntroCard()
                // Card showing stroke symptoms
                StrokeSymptomsCard()
                
                // Display each stroke step
                ForEach(steps) { step in
                    StrokeStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Stroke")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .fontWeight(.regular)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// Introduction card explaining what a stroke is
struct StrokeIntroCard: View {
    // Main container for introduction content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a Stroke?")
                .font(.title2)
                .bold()
            
            Text("A stroke can occur when blood supply to the brain is disrupted and starves the brain of oxygen. It is caused by either a blockage or a bleed in the brain's blood vessels.")
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

// Card showing stroke symptoms and signs
struct StrokeSymptomsCard: View {
    // Main container for symptoms content
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Facial weakness - uneven smile, droopy mouth or eye",
                "Arm weakness - difficulty raising both arms",
                "Speech problems - unclear speech or comprehension",
                "Numbness",
                "Blurred vision",
                "Confusion",
                "Dizziness",
                "Headaches",
                "Feeling or being sick"
            ],
            accentColor: .red,
            warningNote: "Remember FAST: Face, Arms, Speech, Time to call 999"
        )
    }
}

// Card component for each stroke step with instructions and completion tracking
struct StrokeStepCard: View {
    let step: StrokeStep
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
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
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
                                Text(" if they become unresponsive")
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
                        
                        (Text("If they become unresponsive, ")
                            .foregroundColor(.orange) +
                        Text("start CPR")
                            .foregroundColor(.red)
                            .underline())
                            .font(.subheadline)
                            .onTapGesture {
                                showingCPR = true
                            }
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
        StrokeGuidanceView()
    }
}
