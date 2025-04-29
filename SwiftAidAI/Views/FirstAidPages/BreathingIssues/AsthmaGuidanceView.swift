import SwiftUI
import Combine

// Data structure for asthma step information
struct AsthmaStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for asthma guidance with instructions
struct AsthmaGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Define the sequence of steps for managing an asthma attack
    let steps = [
        AsthmaStep(
            number: 1,
            title: "Initial Response",
            icon: "lungs.fill",
            instructions: [
                "Help them sit in a comfortable position.",
                "Keep them calm and reassure them.",
                "Ask them to take their reliever inhaler (usually blue).",
                "If available, use a spacer with the inhaler."
            ],
            warningNote: "A spacer makes the inhaler more effective, especially for children.",
            imageName: "sit"
        ),
        AsthmaStep(
            number: 2,
            title: "Monitor Response",
            icon: "clock.fill",
            instructions: [
                "Wait a few minutes to see if symptoms improve.",
                "If no improvement, this may be a severe attack.",
                "Ask them to take one puff every 30-60 seconds.",
                "Continue until they have taken 10 puffs."
            ],
            warningNote: "If they have no inhaler, call 999 or 112 immediately.",
            imageName: "asthma"
        ),
        AsthmaStep(
            number: 3,
            title: "Emergency Response",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 if:",
                "• The attack is severe or getting worse.",
                "• They are becoming exhausted.", 
                "• This is their first attack.",
                "• They have no inhaler."
            ],
            warningNote: "If ambulance hasn't arrived in 15 minutes, repeat the 10 puffs - start timer.",
            imageName: "call"
        ),
        AsthmaStep(
            number: 4,
            title: "Ongoing Monitoring",
            icon: "heart.text.square.fill",
            instructions: [
                "Monitor their breathing and level of response.",
                "If symptoms improve without calling 999, advise them to see their GP urgently.",
                "Stay with them until they fully recover."
            ],
            warningNote: "If they become unresponsive, prepare to start CPR.",
            imageName: "help"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining asthma
                AsthmaIntroductionCard()
                
                // Display each asthma step
                ForEach(steps) { step in
                    AsthmaStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Asthma Attack")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

// Introduction card explaining what an asthma attack is
struct AsthmaIntroductionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is an Asthma Attack?")
                .font(.title2)
                .bold()
            
            Text("During an asthma attack, the muscles of the airways spasm, narrowing the passages and making breathing difficult. Triggers include colds, drugs, smoke, or allergies, but sometimes there is no clear cause.")
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

// Card component for each asthma step with instructions and completion tracking
struct AsthmaStepCard: View {
    let step: AsthmaStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    // Timer states for monitoring ambulance arrival
    @State private var showTimer = false
    @State private var timeRemaining = 900 // 15 minutes in seconds
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    // Check if text contains emergency numbers
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    // Check if instruction is an emergency call list
    private func isEmergencyCallList(_ instruction: String) -> Bool {
        instruction == "Call 999 or 112 if:"
    }
    
    // Format the remaining time as MM:SS
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the timer
    private func startTimer() {
        if !timerIsRunning {
            timer = Timer.publish(every: 1, on: .main, in: .common)
            timerCancellable = timer.connect()
            timerIsRunning = true
        }
    }
    
    // Stop the timer
    private func stopTimer() {
        if timerIsRunning {
            timerCancellable?.cancel()
            timerIsRunning = false
        }
    }
    
    // Reset the timer to initial 15-minute duration
    private func resetTimer() {
        stopTimer()
        timeRemaining = 900 // Reset to 15 minutes
    }
    
    // Restart the timer from the beginning
    private func restartTimer() {
        resetTimer()
        startTimer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
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
                        .foregroundColor(.blue)
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
            
            // Instructions section with special handling for emergency calls
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if isEmergencyCallList(instruction) {
                            Text(instruction)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.bottom, 4)
                        } else if instruction.hasPrefix("•") {
                            Text(instruction)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.leading, 28)
                                .padding(.vertical, 2)
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
                    }
                }
                
                // Add emergency call buttons if needed
                if step.instructions.contains("Call 999 or 112 if:") {
                    SharedEmergencyCallButtons()
                        .padding(.top, 12)
                }
                
                // Show timer if emergency call is checked
                if showTimer && step.number == 3 {
                    // Show start button only when timer hasn't started and is at initial value
                    if !timerIsRunning && timeRemaining == 900 {
                        HStack {
                            Spacer()
                            Button(action: {
                                startTimer()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 22, weight: .bold))
                                    Text("Start Timer")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(height: 44)
                                .padding(.horizontal, 18)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .accessibilityLabel("Start Timer")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Show timer display when started or when time has been modified
                    if timerIsRunning || timeRemaining < 900 {
                        SharedTimerView(
                            timeRemaining: $timeRemaining,
                            timeRemainingFormatted: timeRemainingFormatted,
                            timerIsRunning: $timerIsRunning,
                            onStart: { startTimer() },
                            onStop: { stopTimer() },
                            onReset: {
                                stopTimer()
                                timeRemaining = 900
                                startTimer()
                            },
                            timerColor: .blue,
                            labelText: "Ambulance Timer: "
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
            }
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        
                        (Text("If they become unresponsive, prepare to ")
                            .foregroundColor(.orange) +
                        Text("start CPR")
                            .foregroundColor(.blue)
                            .underline())
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                    .onTapGesture {
                        showingCPR = true
                    }
                } else if warning.contains("start timer") {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        
                        Text("If the ambulance hasn't arrived in 15 minutes, repeat the 10 puffs")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                    
                    // Show start button only when timer hasn't started and is at initial value
                    if !timerIsRunning && timeRemaining == 900 {
                        HStack {
                            Spacer()
                            Button(action: {
                                startTimer()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 22, weight: .bold))
                                    Text("Start Timer")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(height: 44)
                                .padding(.horizontal, 18)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .accessibilityLabel("Start Timer")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Show timer display when started or when time has been modified
                    if timerIsRunning || timeRemaining < 900 {
                        SharedTimerView(
                            timeRemaining: $timeRemaining,
                            timeRemainingFormatted: timeRemainingFormatted,
                            timerIsRunning: $timerIsRunning,
                            onStart: { startTimer() },
                            onStop: { stopTimer() },
                            onReset: {
                                stopTimer()
                                timeRemaining = 900
                                startTimer()
                            },
                            timerColor: .blue,
                            labelText: "Ambulance Timer: "
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
                } else {
                    WarningNote(text: warning)
                    
                    // Add emergency call buttons if warning contains emergency numbers
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
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
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
        AsthmaGuidanceView()
    }
} 