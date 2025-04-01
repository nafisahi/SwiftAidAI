import SwiftUI

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

struct PrimarySurveyDetailView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        PrimarySurveyStep(
            number: 1,
            letter: "D",
            title: "Danger",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Always check that the area is safe before approaching"
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
                "Approach the casualty carefully and introduce yourself clearly",
                "Kneel next to their chest, gently shake their shoulders",
                "Ask clearly: 'Are you OK?', 'Can you open your eyes?'",
                "If they respond (open eyes, gestures), they are responsive",
                "If no response, they are unresponsive—seek help immediately",
                "Check for catastrophic bleeding (heavy bleeding)",
                "Apply direct pressure immediately if present and call 999 or 112"
            ],
            warningNote: nil,
            imageName: "response 2"
        ),
        PrimarySurveyStep(
            number: 3,
            letter: "A",
            title: "Airway",
            icon: "wind",
            instructions: [
                "Check if the airway is clear",
                "Gently tilt the head back using one hand on the forehead",
                "Lift the chin using two fingers from your other hand"
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
                "With the airway open, place your ear near their mouth, watching their chest",
                "Look, listen, and feel for normal breathing for no more than 10 seconds",
                "If unresponsive and not breathing normally, immediately call 999/112",
                "Start CPR and ask someone to get a defibrillator (AED)"
            ],
            warningNote: "Note: 'Agonal gasping' (slow, noisy gasps) is not normal breathing—this is a sign of cardiac arrest",
            imageName: "breathing 4"
        ),
        PrimarySurveyStep(
            number: 5,
            letter: "C",
            title: "Circulation",
            icon: "heart.fill",
            instructions: [
                "Check quickly for severe bleeding",
                "If severe bleeding, apply direct pressure immediately and call 999/112",
                "If unresponsive but breathing normally and no severe bleeding, place in recovery position"
            ],
            warningNote: nil,
            imageName: "circulation 5"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction Card
                IntroductionCard()
                
                // Steps
                ForEach(steps) { step in
                    PrimarySurveyStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Emergency Actions Card
                EmergencyActionsCard()
                
                // Attribution Footer
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Primary Survey (DR ABC)")
        .navigationBarTitleDisplayMode(.large)
    }
}

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
                .fill(Color.blue.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct PrimarySurveyStepCard: View {
    let step: PrimarySurveyStep
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                // Step Number Circle
                ZStack {
                    Circle()
                        .fill(Color.blue)
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
                        .foregroundColor(.blue)
                }
            }
            
            // Add the image
            if let uiImage = UIImage(named: step.imageName) {
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
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                    
                    Text(warning)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }
}

struct EmergencyActionsCard: View {
    @State private var showingCPR = false
    @State private var showingRecoveryPosition = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Steps")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { showingCPR = true }) {
                    ActionItem(
                        icon: "xmark.circle.fill",
                        color: .red,
                        text: "If casualty is not breathing, immediately start CPR",
                        isLink: true
                    )
                }
                
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
        .sheet(isPresented: $showingCPR) {
            NavigationStack {
                CPRGuidanceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingCPR = false
                    })
            }
        }
        .sheet(isPresented: $showingRecoveryPosition) {
            NavigationStack {
                RecoveryPositionView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingRecoveryPosition = false
                    })
            }
        }
    }
}

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
                .foregroundColor(isLink ? .blue : .primary)
                .underline(isLink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

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
                        .foregroundColor(.blue)
                    
                    Image(systemName: "link")
                        .font(.footnote)
                        .foregroundColor(.blue)
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
