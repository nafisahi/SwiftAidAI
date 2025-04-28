import SwiftUI

// Data structure for recovery position step information
struct RecoveryStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for recovery position guidance with step-by-step instructions
struct RecoveryPositionView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    
    // Add a parameter to determine if this is shown from critical emergencies
    var isFromCriticalEmergencies: Bool = false
    
    let steps = [
        RecoveryStep(
            number: 1,
            title: "Initial Assessment",
            icon: "checklist",
            instructions: [
                "Perform primary survey to assess the casualty",
                "Ensure they are breathing normally",
                "Check for any injuries that may be worsened by movement"
            ],
            warningNote: nil,
            imageName: "recovery-step1"
        ),
        RecoveryStep(
            number: 2,
            title: "Straighten Legs",
            icon: "figure.walk",
            instructions: [
                "Kneel beside the casualty and straighten their legs carefully.",
                "Remove glasses and bulky items from pockets; avoid searching for smaller items."
            ],
            warningNote: nil,
            imageName: "step2-adult-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 3,
            title: "Arm Positioning",
            icon: "arrow.up.right",
            instructions: [
                "Place the arm nearest you at a right angle to their body, elbow bent, palm facing upwards."
            ],
            warningNote: nil,
            imageName: "step3-adult-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 4,
            title: "Bring Other Arm Across",
            icon: "arrow.left.and.right",
            instructions: [
                "Bring their far arm across their chest.",
                "Place the back of their hand against the cheek nearest to you and hold it in place."
            ],
            warningNote: nil,
            imageName: "step4-adult-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 5,
            title: "Position the Leg",
            icon: "figure.walk",
            instructions: [
                "Using your other hand, pull their far knee upwards so their foot is flat on the floor."
            ],
            warningNote: nil,
            imageName: "step5-correct1-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 6,
            title: "Roll onto Side",
            icon: "arrow.triangle.2.circlepath",
            instructions: [
                "Keeping the back of their hand against their cheek, gently pull on their far leg to roll them towards you onto their side.",
                "Adjust their top leg so their knee and hip are bent at right angles."
            ],
            warningNote: nil,
            imageName: "step6-adult-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 7,
            title: "Final Adjustments",
            icon: "checkmark.circle",
            instructions: [
                "Tilt their head back gently and lift their chin to keep the airway open.",
                "Adjust their hand beneath their cheek if necessary."
            ],
            warningNote: nil,
            imageName: "step7-adult-recovery-position-first-aid"
        ),
        RecoveryStep(
            number: 8,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Dial 999 or 112 immediately if not done already.",
                "Continuously monitor their breathing and responsiveness while awaiting help."
            ],
            warningNote: nil,
            imageName: "calling-for-help---male-2"
        )
    ]
    // Main view body showing recovery position steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining recovery position
                RecoveryIntroductionCard()
                
                // Display each recovery position step
                ForEach(steps) { step in
                    RecoveryStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Unresponsive but Breathing")
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
        .presentationDragIndicator(.visible)
    }
}

// Introduction card explaining when to use recovery position
struct RecoveryIntroductionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to Use the Recovery Position")
                .font(.title2)
                .bold()
            
            Text("Place someone in the recovery position if they are unresponsive but breathing normally. This position keeps the airway clear and allows any vomit or fluids to drain safely.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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

// Card component for each recovery position step with instructions and completion tracking
struct RecoveryStepCard: View {
    let step: RecoveryStep
    @Binding var completedSteps: Set<String>
    @State private var showingPrimarySurvey = false
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main container for step content
            HStack(alignment: .center, spacing: 16) {
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
                HStack(spacing: 8) {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Add the image if available
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
                        // Special handling for primary survey instruction in step 1
                        if step.number == 1 && instruction.contains("primary survey") {
                            // Custom row with tappable "primary survey" text that opens detail sheet
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                    .font(.system(size: 20))
                                
                                (Text("Perform ")
                                    .foregroundColor(.primary) +
                                Text("primary survey")
                                    .foregroundColor(.red)
                                    .underline() +
                                Text(" to assess the casualty")
                                    .foregroundColor(.primary))
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showingPrimarySurvey = true
                                    }
                                
                                Spacer()
                            }
                        } else {
                            // Standard checkbox row for other instructions
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
                }
            }
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                WarningNote(text: warning)
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
        // Sheet presentation for primary survey details
        .sheet(isPresented: $showingPrimarySurvey) {
            PrimarySurveyDetailView()
                .presentationDragIndicator(.visible)
        }
    }
}

// Utility for programmatic navigation between views
struct NavigationUtil {
    static func navigate(to view: some View) {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        let rootViewController = keyWindow?.rootViewController
        let hostingController = UIHostingController(rootView: view)
        rootViewController?.present(hostingController, animated: true)
    }
}

#Preview {
    NavigationStack {
        RecoveryPositionView()
    }
} 
