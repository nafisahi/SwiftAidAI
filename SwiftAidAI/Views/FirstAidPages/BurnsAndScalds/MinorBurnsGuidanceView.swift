import SwiftUI
import Combine

// Data structure for minor burn step information with unique ID, number, title, icon, instructions, warning note, and optional image
struct MinorBurnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for minor burns guidance with instructions
struct MinorBurnsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of minor burn treatment steps
    let steps = [
        MinorBurnStep(
            number: 1,
            title: "Cool the Burn",
            icon: "drop.fill",
            instructions: [
                "Start cooling immediately under cool running water.",
                "Continue for at least 20 minutes or until pain feels better.",
                "If no water available, use cold milk or canned drinks."
            ],
            warningNote: nil,
            imageName: "minor-1"
        ),
        MinorBurnStep(
            number: 2,
            title: "Remove Restrictions",
            icon: "hand.raised.fill",
            instructions: [
                "Remove any jewellery or clothing.",
                "Do this before the area begins to swell.",
                "Do not remove if stuck to the burn."
            ],
            warningNote: "Remove items carefully to avoid further damage.",
            imageName: "minor-2"
        ),
        MinorBurnStep(
            number: 3,
            title: "Cover the Burn",
            icon: "bandage.fill",
            instructions: [
                "Once cooled, cover loosely with cling film lengthways.",
                "Do not wrap cling film around the burn.",
                "For hands/feet, use a clean plastic bag.",
                "Do not use ice, creams or gels."
            ],
            warningNote: "Do not break any blisters that may appear - this can cause infection.",
            imageName: "minor-3"
        ),
        MinorBurnStep(
            number: 4,
            title: "Monitor and Seek Help",
            icon: "person.fill.checkmark",
            instructions: [
                "Monitor the casualty's condition.",
                "Seek medical advice if concerned.",
                "Watch for signs of infection.",
                "Call 999 or 112 if condition worsens."
            ],
            warningNote: nil,
            imageName: "minor-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction card explaining minor burns
                MinorBurnIntroCard()
                
                // Display each minor burn treatment step
                ForEach(steps) { step in
                    MinorBurnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution information
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Minor Burns and Scalds")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                        Text("Back")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// Introduction card explaining what minor burns and scalds are
struct MinorBurnIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are Burns and Scalds?")
                .font(.title2)
                .bold()
            
            Text("Burns are caused by dry heat (fire, hot iron, sun) and scalds by wet heat (steam, hot liquids). Cool the burn quickly to prevent severe injury.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card component for each minor burn step with instructions, completion tracking, and timer functionality
struct MinorBurnStepCard: View {
    let step: MinorBurnStep
    @Binding var completedSteps: Set<String>
    
    // Timer states for tracking the cooling period
    @State private var showTimer = false
    @State private var timeRemaining = 1200 // 20 minutes in seconds
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    // Format the remaining time as MM:SS
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the timer for cooling period
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
    
    // Reset the timer to initial 20-minute duration
    private func resetTimer() {
        stopTimer()
        timeRemaining = 1200 // Reset to 20 minutes
    }
    
    // Restart the timer from the beginning
    private func restartTimer() {
        resetTimer()
        startTimer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with numbered circle, title, and icon
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                Text(step.title)
                    .font(.headline)
                    .bold()
                
                Image(systemName: step.icon)
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            // Display the step image if available
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions as interactive checklist
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: completedSteps.contains("\(step.id)-\(instruction)") ? "checkmark.square.fill" : "square")
                                .foregroundColor(completedSteps.contains("\(step.id)-\(instruction)") ? .green : .gray)
                                .onTapGesture {
                                    if completedSteps.contains("\(step.id)-\(instruction)") {
                                        completedSteps.remove("\(step.id)-\(instruction)")
                                        if instruction.contains("Start cooling immediately under cool running water") {
                                            showTimer = false
                                            stopTimer()
                                        }
                                    } else {
                                        completedSteps.insert("\(step.id)-\(instruction)")
                                        if instruction.contains("Start cooling immediately under cool running water") {
                                            showTimer = true
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show start button for cooling instruction when timer hasn't started
                        if instruction.contains("Start cooling immediately under cool running water") && !timerIsRunning && timeRemaining == 1200 {
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
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                                .accessibilityLabel("Start Timer")
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Show timer for cooling instruction when active
                        if instruction.contains("Start cooling immediately under cool running water") && (timerIsRunning || timeRemaining < 1200) {
                            SharedTimerView(
                                timeRemaining: $timeRemaining,
                                timeRemainingFormatted: timeRemainingFormatted,
                                timerIsRunning: $timerIsRunning,
                                onStart: { startTimer() },
                                onStop: { stopTimer() },
                                onReset: { restartTimer() },
                                timerColor: .orange,
                                labelText: "Cooling Timer: "
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
                        
                        // Show emergency call buttons for emergency number instructions
                        if instruction.contains("999") || instruction.contains("112") {
                            SharedEmergencyCallButtons()
                                .padding(.top, 4)
                                .padding(.leading, 32)
                        }
                    }
                }
            }
            
            // Display warning note if present
            if let warning = step.warningNote {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(warning)
                        .font(.subheadline)
                        .foregroundColor(.orange)
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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
} 

#Preview {
    NavigationStack {
        MinorBurnsGuidanceView()
    }
}
