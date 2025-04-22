import SwiftUI

struct ChokingStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct ChokingGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    let steps = [
        ChokingStep(
            number: 1,
            title: "Check if They Are Choking",
            icon: "person.fill.questionmark",
            instructions: [
                "Ask clearly, 'Are you choking?'",
                "If they can breathe, speak, or cough, encourage coughing.",
                "If they cannot breathe, cough, or make noise, act immediately."
            ],
            warningNote: nil,
            imageName: "step1adult-choking-first-aid-advice"
        ),
        ChokingStep(
            number: 2,
            title: "Encourage to Cough",
            icon: "lungs.fill",
            instructions: [
                "Ask them to cough strongly to clear any obstruction.",
                "Remove visible objects carefully from their mouth."
            ],
            warningNote: nil,
            imageName: "step-2-adult-choking-first-aid-advice"
        ),
        ChokingStep(
            number: 3,
            title: "Give Back Blows",
            icon: "hand.raised.fill",
            instructions: [
                "Help them lean forward; support their chest with one hand.",
                "Deliver five sharp blows between their shoulder blades using the heel of your other hand.",
                "Check after each blow if the blockage clears."
            ],
            warningNote: nil,
            imageName: "step3-adult-choking-first-aid-advice"
        ),
        ChokingStep(
            number: 4,
            title: "Give Abdominal Thrusts",
            icon: "arrow.up.forward",
            instructions: [
                "Stand behind them, wrap your arms around their waist.",
                "Clench one fist and place it between their belly button and chest.",
                "Grasp your fist with your other hand and pull sharply inward and upward, up to five times.",
                "Check mouth after each thrust."
            ],
            warningNote: "Only perform if back blows fail",
            imageName: "step4-adult-choking-first-aid-advice"
        ),
        ChokingStep(
            number: 5,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "If blockage remains, immediately call 999 or 112.",
                "Continue cycles of five back blows and five abdominal thrusts, checking after each, until help arrives."
            ],
            warningNote: "If they become unresponsive, start CPR immediately.",
            imageName: "step5-adult-choking-first-aid-advice"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ChokingIntroductionCard()
                
                // Steps
                ForEach(steps) { step in
                    ChokingStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Continue Until Card
                ContinueUntilCard()
                
                // Attribution Footer
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Choking")
        .navigationBarTitleDisplayMode(.automatic)
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

struct ChokingIntroductionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            // What is Choking explanation
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Choking?")
                    .font(.title2)
                    .bold()
                
                Text("When someone is choking, their airway is partly or completely blocked. They might be unable to breathe, speak, or cough effectively.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
            )
            
            // Symptoms card
            ChokingSymptomsCard()
        }
        .padding(.horizontal)
    }
}

struct ChokingSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Difficulty breathing, speaking, or coughing",
                "Red, puffy face",
                "Signs of distress; pointing to throat or grasping the neck"
            ],
            accentColor: .red,
            warningNote: nil
        )
    }
}

struct ChokingStepCard: View {
    let step: ChokingStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            
            // Add the image if available
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
                        
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
                
                if let warning = step.warningNote {
                    if step.number == 5 {
                        CPRWarningNote(showingCPR: $showingCPR)
                    } else {
                        WarningNote(text: warning)
                        if hasEmergencyNumbers(warning) {
                            SharedEmergencyCallButtons()
                                .padding(.top, 4)
                        }
                    }
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
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
}

#Preview {
    NavigationStack {
        ChokingGuidanceView()
    }
} 
