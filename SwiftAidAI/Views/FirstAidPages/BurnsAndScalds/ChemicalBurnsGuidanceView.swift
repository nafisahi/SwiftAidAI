import SwiftUI
import Combine

struct ChemicalBurnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct ChemicalBurnStepCard: View {
    let step: ChemicalBurnStep
    @Binding var completedSteps: Set<String>
    
    // Add timer states
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
    
    // Start the timer
    private func startTimer() {
        timeRemaining = 1200 // Reset to 20 minutes
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
            // Header with numbered circle
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
            
            // Add the image if present
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions as checklist
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
                                            startTimer()
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show timer for cooling instruction
                        if instruction.contains("Flood with cool running water") && showTimer {
                            SharedTimerView(
                                timeRemaining: $timeRemaining,
                                timeRemainingFormatted: timeRemainingFormatted,
                                timerIsRunning: $timerIsRunning,
                                onStart: { startTimer() },
                                onStop: { stopTimer() },
                                onReset: {
                                    stopTimer()
                                    timeRemaining = 1200  // Reset to 20 minutes
                                    startTimer()
                                },
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
                        
                        // Show emergency call buttons
                        if instruction.contains("999") || instruction.contains("112") {
                            SharedEmergencyCallButtons()
                                .padding(.top, 4)
                                .padding(.leading, 32)
                        }
                    }
                }
            }
            
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

struct ChemicalBurnsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        ChemicalBurnStep(
            number: 1,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help",
                "Pass on any details about the chemical to ambulance control",
                "If possible, ask someone else to call so you can continue treatment"
            ],
            warningNote: "Chemical burns can be life-threatening - get help immediately",
            imageName: "chemical-burn-1"
        ),
        ChemicalBurnStep(
            number: 2,
            title: "Ensure Safety & Protection",
            icon: "hand.raised.fill",
            instructions: [
                "Wear protective gloves if available",
                "Use apron and eye protection if possible",
                "Ventilate the area by opening windows/doors",
                "Remove casualty from contaminated area if safe"
            ],
            warningNote: "Protect yourself to avoid chemical contact",
            imageName: "chemical-burn-2"
        ),
        ChemicalBurnStep(
            number: 3,
            title: "Remove Chemical",
            icon: "arrow.up.circle.fill",
            instructions: [
                "Brush/pat off powder chemicals if present",
                "Remove contaminated clothing",
                "Seal chemical container if safe to do so"
            ],
            warningNote: "Do not touch chemicals directly",
            imageName: "chemical-burn-3"
        ),
        ChemicalBurnStep(
            number: 4,
            title: "Cool the Burn",
            icon: "drop.fill",
            instructions: [
                "Flood with cool running water for at least 20 minutes",
                "Pour water away from yourself to avoid splashes",
                "Ensure contaminated water doesn't collect near casualty",
                "Do not search for antidotes or try to neutralize chemicals"
            ],
            warningNote: "Never attempt to neutralize acids or alkalis unless trained",
            imageName: "chemical-burn-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ChemicalBurnIntroCard()
                
                ForEach(steps) { step in
                    ChemicalBurnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Chemical Burns")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ChemicalBurnIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a chemical burn?")
                .font(.title2)
                .bold()
            
            Text("A chemical burn occurs when strong acids or alkalis come into contact with the skin or eyes.")
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