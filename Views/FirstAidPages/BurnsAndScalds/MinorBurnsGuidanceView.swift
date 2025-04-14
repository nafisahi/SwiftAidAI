import SwiftUI
import Combine

struct MinorBurnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct MinorBurnsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    
    let steps = [
        MinorBurnStep(
            number: 1,
            title: "Cool the Burn",
            icon: "drop.fill",
            instructions: [
                "Start cooling immediately under cool running water",
                "Continue for at least 20 minutes or until pain feels better",
                "If no water available, use cold milk or canned drinks"
            ],
            warningNote: nil,
            imageName: "minor-1"
        ),
        MinorBurnStep(
            number: 2,
            title: "Remove Restrictions",
            icon: "hand.raised.fill",
            instructions: [
                "Remove any jewellery or clothing",
                "Do this before the area begins to swell",
                "Do not remove if stuck to the burn"
            ],
            warningNote: "Remove items carefully to avoid further damage",
            imageName: "minor-2"
        ),
        MinorBurnStep(
            number: 3,
            title: "Cover the Burn",
            icon: "bandage.fill",
            instructions: [
                "Once cooled, cover loosely with cling film lengthways",
                "Do not wrap cling film around the burn",
                "For hands/feet, use a clean plastic bag",
                "Do not use ice, creams or gels"
            ],
            warningNote: "Do not break any blisters that may appear - this can cause infection",
            imageName: "minor-3"
        ),
        MinorBurnStep(
            number: 4,
            title: "Monitor and Seek Help",
            icon: "person.fill.checkmark",
            instructions: [
                "Monitor the casualty's condition",
                "Seek medical advice if concerned",
                "Watch for signs of infection",
                "Call 999 or 112 if condition worsens"
            ],
            warningNote: nil,
            imageName: "minor-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MinorBurnIntroCard()
                
                ForEach(steps) { step in
                    MinorBurnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Minor Burns and Scalds")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MinorBurnIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are Burns and Scalds?")
                .font(.title2)
                .bold()
            
            Text("Burns are caused by dry heat (fire, hot iron, sun) and scalds by wet heat (steam, hot liquids). Cool the burn quickly to prevent severe injury.")
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

struct MinorBurnStepCard: View {
    let step: MinorBurnStep
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
                                            startTimer()
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show timer for cooling instruction
                        if instruction.contains("Start cooling immediately under cool running water") && showTimer {
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
                    }
                    
                    // Add emergency call buttons if instruction mentions emergency numbers
                    if instruction.contains("999") || instruction.contains("112") {
                        SharedEmergencyCallButtons()
                            .padding(.top, 4)
                            .padding(.leading, 32)
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
#Preview {
    NavigationStack {
        MinorBurnsGuidanceView()
    }
}
