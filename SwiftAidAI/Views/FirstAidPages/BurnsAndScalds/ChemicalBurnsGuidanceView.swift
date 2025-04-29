import SwiftUI
import Combine

// Data structure for chemical burn step information with unique ID, number, title, icon, instructions, warning note, and optional image
struct ChemicalBurnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Card component for each chemical burn step with instructions, completion tracking, and timer functionality
struct ChemicalBurnStepCard: View {
    let step: ChemicalBurnStep
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
                            Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                .onTapGesture {
                                    if completedSteps.contains(instruction) {
                                        completedSteps.remove(instruction)
                                        if instruction.contains("Flood with cool running water") {
                                            showTimer = false
                                            stopTimer()
                                        }
                                    } else {
                                        completedSteps.insert(instruction)
                                        if instruction.contains("Flood with cool running water") {
                                            showTimer = true
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show start button for cooling instruction when timer hasn't started
                        if instruction.contains("Flood with cool running water") && !timerIsRunning && timeRemaining == 1200 {
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
                        if instruction.contains("Flood with cool running water") && (timerIsRunning || timeRemaining < 1200) {
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

// Main view for chemical burns guidance with instructions
struct ChemicalBurnsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of chemical burn treatment steps
    let steps = [
        ChemicalBurnStep(
            number: 1,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help.",
                "Pass on any details about the chemical to ambulance control.",
                "If possible, ask someone else to call so you can continue treatment."
            ],
            warningNote: "Chemical burns can be life-threatening - get help immediately.",
            imageName: "chemical-burn-1"
        ),
        ChemicalBurnStep(
            number: 2,
            title: "Ensure Safety & Protection",
            icon: "hand.raised.fill",
            instructions: [
                "Wear protective gloves if available.",
                "Use apron and eye protection if possible.",
                "Ventilate the area by opening windows/doors.",
                "Remove casualty from contaminated area if safe."
            ],
            warningNote: "Protect yourself to avoid chemical contact.",
            imageName: "chemical-burn-2"
        ),
        ChemicalBurnStep(
            number: 3,
            title: "Remove Chemical",
            icon: "arrow.up.circle.fill",
            instructions: [
                "Brush/pat off powder chemicals if present.",
                "Remove contaminated clothing.",
                "Seal chemical container if safe to do so."
            ],
            warningNote: "Do not touch chemicals directly.",
            imageName: "chemical-burn-3"
        ),
        ChemicalBurnStep(
            number: 4,
            title: "Cool the Burn",
            icon: "drop.fill",
            instructions: [
                "Flood with cool running water for at least 20 minutes.",
                "Pour water away from yourself to avoid splashes.",
                "Ensure contaminated water doesn't collect near casualty.",
                "Do not search for antidotes or try to neutralize chemicals."
            ],
            warningNote: "Never attempt to neutralize acids or alkalis unless trained.",
            imageName: "chemical-burn-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction card explaining chemical burns
                ChemicalBurnIntroCard()
                
                // Display each chemical burn treatment step
                ForEach(steps) { step in
                    ChemicalBurnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution information
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Chemical Burns")
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

// Introduction card explaining what chemical burns are
struct ChemicalBurnIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a chemical burn?")
                .font(.title2)
                .bold()
            
            Text("A chemical burn occurs when strong acids or alkalis come into contact with the skin or eyes.")
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

#Preview {
    NavigationStack {
        ChemicalBurnsGuidanceView()
    }
}