import SwiftUI
import Combine

// Data structure for nosebleed step information with unique ID, number, title, icon, instructions, and optional warning/image
struct NosebleedStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for nosebleed guidance with instructions, completion tracking, and timer functionality
struct NosebleedGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    
    // Predefined list of nosebleed treatment steps with detailed instructions and visual aids
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
    
    // Main view body showing nosebleed treatment steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining nosebleeds
                NosebleedIntroCard()
                
                // Display each treatment step with completion tracking
                ForEach(steps) { step in
                    NosebleedStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Nosebleeds")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
            }
        }
    }
}

// Introduction card explaining what nosebleeds are and their causes
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

// Card component for each nosebleed step with instructions, completion tracking, and timer functionality
struct NosebleedStepCard: View {
    let step: NosebleedStep
    @Binding var completedSteps: Set<String>
    
    // States for timer functionality
    @State private var timeRemaining = 600 // 10 minutes in seconds
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    // Check if warning note contains emergency phone numbers
    private var warningHasEmergencyNumbers: Bool {
        if let warning = step.warningNote {
            return warning.contains("999") || warning.contains("112")
        }
        return false
    }
    
    // Format remaining time for timer display
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the timer for nose pinching countdown
    private func startTimer() {
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
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator with red background
                ZStack {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.2, blue: 0.2))
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
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
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
            
            // Timer section for nose pinching step
            if step.number == 2 {
                // Show start button only when timer hasn't started and is at initial value
                if !timerIsRunning && timeRemaining == 600 {
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
                            .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Start Timer")
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Show timer display when started or when time has been modified
                if timerIsRunning || timeRemaining < 600 {
                    SharedTimerView(
                        timeRemaining: $timeRemaining,
                        timeRemainingFormatted: timeRemainingFormatted,
                        timerIsRunning: $timerIsRunning,
                        onStart: { startTimer() },
                        onStop: { stopTimer() },
                        onReset: {
                            stopTimer()
                            timeRemaining = 600
                            startTimer()
                        },
                        timerColor: Color(red: 0.8, green: 0.2, blue: 0.2),
                        labelText: "Nose Pinching Timer: "
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
            
            // Instructions section containing checkboxes for each step
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
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                WarningNote(text: warning)
                
                // Add emergency call buttons if the warning mentions emergency numbers
                if warningHasEmergencyNumbers {
                    SharedEmergencyCallButtons()
                        .padding(.top, 8)
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
