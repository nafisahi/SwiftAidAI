import SwiftUI

struct CPRStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String
}

struct CPRGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        CPRStep(
            number: 1,
            title: "Check for Breathing",
            icon: "lungs.fill",
            instructions: [
                "Ensure it's safe to approach",
                "Check responsiveness by gently shaking their shoulders and loudly asking, 'Are you OK?'",
                "If no response, shout for help",
                "Open the airway by gently tilting their head back and lifting the chin",
                "Look, listen, and feel for normal breathing for up to 10 seconds"
            ],
            warningNote: "Ignore occasional gasps—these are not normal breathing",
            imageName: "adult-step-1-cpr"
        ),
        CPRStep(
            number: 2,
            title: "Call for Help",
            icon: "phone.fill",
            instructions: [
                "Immediately ask someone to call 999 or 112",
                "Ask someone else to bring a defibrillator (AED), if available",
                "Put the phone on speaker if alone, allowing hands-free communication with emergency services"
            ],
            warningNote: nil,
            imageName: "call-help2"
        ),
        CPRStep(
            number: 3,
            title: "Start Chest Compressions",
            icon: "heart.fill",
            instructions: [
                "Place the heel of one hand in the center of their chest",
                "Place your other hand on top and interlock your fingers",
                "Keep your arms straight and position your shoulders above your hands",
                "Press down hard and fast, at least 5-6cm deep",
                "Allow complete chest recoil after each compression",
                "Aim for a rate of 100-120 compressions per minute"
            ],
            warningNote: "Maintain the correct rhythm—about 2 compressions per second",
            imageName: "cpr-step-3"
        ),
        CPRStep(
            number: 4,
            title: "Give Rescue Breaths",
            icon: "wind",
            instructions: [
                "After 30 compressions, give 2 rescue breaths",
                "Tilt their head back gently and lift the chin",
                "Pinch their nose closed",
                "Take a normal breath and seal your mouth around theirs",
                "Blow steadily for about 1 second",
                "Watch for their chest to rise",
                "Give a second breath and return to compressions"
            ],
            warningNote: "If you're unable or unwilling to give rescue breaths, continue chest compressions only",
            imageName: "cpr-step-3"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CPRIntroductionCard()
                
                // Steps
                ForEach(steps) { step in
                    CPRStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Continue Until Card
                ContinueUntilCard()
                
                // Attribution Footer
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Unresponsive and Not Breathing (CPR)")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct CPRIntroductionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is CPR?")
                .font(.title2)
                .bold()
            
            Text("CPR stands for cardiopulmonary resuscitation. It involves chest compressions and rescue breaths to maximize the chance of survival after a cardiac arrest.")
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

struct CPRStepCard: View {
    let step: CPRStep
    @Binding var completedSteps: Set<String>
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red)
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
                        .foregroundColor(.red)
                }
            }
            
            // Add the image if present
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
            }
            
            // Warning note if present
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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct ContinueUntilCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue CPR Until:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ContinueUntilItem(text: "Emergency services arrive")
                ContinueUntilItem(text: "The casualty shows signs of life or normal breathing")
                ContinueUntilItem(text: "You are physically unable to continue (swap with someone else if possible, every 1-2 minutes)")
                ContinueUntilItem(text: "A defibrillator is ready for use")
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

struct ContinueUntilItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.clockwise")
                .foregroundColor(.red)
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        CPRGuidanceView()
    }
} 
