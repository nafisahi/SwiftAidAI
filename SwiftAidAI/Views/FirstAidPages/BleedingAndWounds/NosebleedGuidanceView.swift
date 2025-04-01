import SwiftUI
import Combine

struct NosebleedStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct NosebleedGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        NosebleedStep(
            number: 1,
            title: "Sit Down & Lean Forward",
            icon: "person.fill",
            instructions: [
                "Ask them to sit down and lean with their head tilted forward",
                "Ask them to breathe through their mouth",
                "Give them a clean tissue to catch any blood"
            ],
            warningNote: "Do NOT tilt the head back as this could cause blood to trickle down the back of their throat and block the airway",
            imageName: "nosebleed-1"
        ),
        NosebleedStep(
            number: 2,
            title: "Pinch the Nose",
            icon: "hand.point.up.fill",
            instructions: [
                "Ask them to pinch the soft part of their nose",
                "Hold pressure for 10 minutes",
                "After 10 minutes, they can release the pressure on their nose"
            ],
            warningNote: "If bleeding continues, pinch again for two further periods of 10 minutes",
            imageName: "nosebleed-1"
        ),
        NosebleedStep(
            number: 3,
            title: "After Bleeding Stops",
            icon: "checkmark.circle.fill",
            instructions: [
                "Clean around their nose with lukewarm water",
                "Advise them to rest",
                "Tell them to avoid exertion or blowing their nose to prevent disturbing the clots"
            ],
            warningNote: "If the bleeding is severe, or if it lasts more than 30 minutes, call 999 or 112 for emergency help",
            imageName: "nosebleed-2"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NosebleedIntroCard()
                
                ForEach(steps) { step in
                    NosebleedStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Nosebleeds")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct NosebleedIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a nosebleed and what causes them?")
                .font(.title2)
                .bold()
            
            Text("A nosebleed occurs when tiny blood vessels in the nostrils rupture. Causes include injury, sneezing, picking, blowing, high blood pressure, and medication.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct NosebleedStepCard: View {
    let step: NosebleedStep
    @Binding var completedSteps: Set<String>
    
    // States for timer functionality
    @State private var showTimer = false
    @State private var timeRemaining = 600 // 10 minutes in seconds
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    // Add a computed property to check if this step has emergency call instructions
    private var hasEmergencyCallInstructions: Bool {
        for instruction in step.instructions {
            if instruction.contains("999") || instruction.contains("112") {
                return true
            }
        }
        return false
    }
    
    // Check if warning note contains emergency numbers
    private var warningHasEmergencyNumbers: Bool {
        if let warning = step.warningNote {
            return warning.contains("999") || warning.contains("112")
        }
        return false
    }
    
    // Check if this step contains the pressure instruction
    private var containsPressureInstruction: Bool {
        for instruction in step.instructions {
            if instruction.contains("Hold pressure for 10 minutes") {
                return true
            }
        }
        return false
    }
    
    // Format the remaining time as MM:SS
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the timer
    private func startTimer() {
        timeRemaining = 600 // Reset to 10 minutes
        timer = Timer.publish(every: 1, on: .main, in: .common)
        timerCancellable = timer.connect()
        timerIsRunning = true
    }
    
    // Stop the timer
    private func stopTimer() {
        timerCancellable?.cancel()
        timerIsRunning = false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.2, blue: 0.2))
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
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
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
                    CheckboxRow(
                        text: instruction,
                        isChecked: completedSteps.contains(instruction),
                        action: {
                            // Toggle the step completion
                            if completedSteps.contains(instruction) {
                                completedSteps.remove(instruction)
                                // If unchecking the pressure instruction, hide timer
                                if instruction.contains("Hold pressure for 10 minutes") {
                                    showTimer = false
                                    stopTimer()
                                }
                            } else {
                                completedSteps.insert(instruction)
                                // If checking the pressure instruction, show timer
                                if instruction.contains("Hold pressure for 10 minutes") {
                                    showTimer = true
                                    startTimer()
                                }
                            }
                        }
                    )
                    
                    // Show timer after the pressure instruction if checked
                    if instruction.contains("Hold pressure for 10 minutes") && showTimer {
                        SharedTimerView(
                            timeRemaining: $timeRemaining,
                            timeRemainingFormatted: timeRemainingFormatted,
                            timerIsRunning: $timerIsRunning,
                            onStart: { startTimer() },
                            onStop: { stopTimer() },
                            onReset: {
                                stopTimer()
                                timeRemaining = 600  // Keep 10 minutes for nosebleeds
                                startTimer()
                            },
                            timerColor: Color(red: 0.8, green: 0.2, blue: 0.2),
                            labelText: "Pressure Timer: "
                        )
                        .padding(.leading, 28)
                        .padding(.vertical, 8)
                        .onReceive(timer) { _ in
                            if timerIsRunning && timeRemaining > 0 {
                                timeRemaining -= 1
                            } else if timeRemaining == 0 {
                                stopTimer()
                            }
                        }
                    }
                }
                
                // Add emergency call buttons if this step has emergency instructions
                if hasEmergencyCallInstructions {
                    SharedEmergencyCallButtons()
                        .padding(.top, 8)
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                WarningNote(text: warning)
                
                // Add emergency call buttons if the warning mentions emergency numbers
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
                .stroke(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        NosebleedGuidanceView()
    }
} 
