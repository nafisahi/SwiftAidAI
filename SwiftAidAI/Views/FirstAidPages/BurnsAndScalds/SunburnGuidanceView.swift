import SwiftUI
import Combine  // Add this for timer functionality

// Data structure for sunburn step information with unique ID, number, title, icon, instructions, warning note, and optional image
struct SunburnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Card component for each sunburn step with instructions, completion tracking, and timer functionality
struct SunburnStepCard: View {
    let step: SunburnStep
    @Binding var completedSteps: Set<String>
    
    // Timer states for tracking the cooling period
    @State private var showTimer = false
    @State private var timeRemaining = 600 // 10 minutes in seconds
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
    
    // Reset the timer to initial 10-minute duration
    private func resetTimer() {
        stopTimer()
        timeRemaining = 600 // Reset to 10 minutes
    }
    
    // Restart the timer from the beginning
    private func restartTimer() {
        resetTimer()
        startTimer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with numbered circle, title, and icon
            HStack(alignment: .center, spacing: 16) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
                                        if instruction.contains("Cool the skin with cool water for 10 minutes") {
                                            showTimer = false
                                            stopTimer()
                                        }
                                    } else {
                                        completedSteps.insert("\(step.id)-\(instruction)")
                                        if instruction.contains("Cool the skin with cool water for 10 minutes") {
                                            showTimer = true
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show start button for cooling instruction when timer hasn't started
                        if instruction.contains("Cool the skin with cool water for 10 minutes") && !timerIsRunning && timeRemaining == 600 {
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
                        if instruction.contains("Cool the skin with cool water for 10 minutes") && (timerIsRunning || timeRemaining < 600) {
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
        .frame(maxWidth: .infinity)
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

// Main view for sunburn guidance with instructions
struct SunburnGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of sunburn treatment steps
    let steps = [
        SunburnStep(
            number: 1,
            title: "Move to Shade",
            icon: "sun.max.fill",
            instructions: [
                "Move person out of the sun immediately. ",
                "Cover the skin with light clothing.",
                "Find a cool, shaded area."
            ],
            warningNote: nil,
            imageName: "sunburn-1"
        ),
        SunburnStep(
            number: 2,
            title: "Cool and Hydrate",
            icon: "drop.fill",
            instructions: [
                "Give them cold water to sip.",
                "Cool the skin with cool water for 10 minutes.",
                "Do not use ice or very cold water."
            ],
            warningNote: "Stay hydrated to prevent heat exhaustion.",
            imageName: "sunburn-2"
        ),
        SunburnStep(
            number: 3,
            title: "Treat the Burn",
            icon: "bandage.fill",
            instructions: [
                "Apply calamine lotion to soothe mild sunburn.",
                "Do not burst any blisters.",
                "Keep the affected area covered with loose clothing."
            ],
            warningNote: "If there are blisters, seek professional medical advice.",
            imageName: "sunburn-3"
        ),
        SunburnStep(
            number: 4,
            title: "Monitor",
            icon: "eye.fill",
            instructions: [
                "Watch for signs of heat exhaustion or heatstroke.",
                "Get medical help if symptoms are severe.",
                "Look out for extensive blistering."
            ],
            warningNote: "Severe sunburn with blistering requires medical attention ",
            imageName: "sunburn-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction card explaining sunburn
                SunburnIntroCard()
                
                // Display each sunburn treatment step
                ForEach(steps) { step in
                    SunburnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution information
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Sunburn")
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

// Introduction card explaining what sunburn is
struct SunburnIntroCard: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Sunburn?")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Sunburn is skin damage caused by ultraviolet (UV) rays. The skin becomes red, warm, sore and tender. It may start to flake and peel after a few days. In some cases it can be severe and require medical treatment.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.1))
            )
        }
        .padding(.horizontal)
    }
}

// Card displaying signs and symptoms of sunburn
struct SunburnSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Red, warm skin that is painful to touch",
                "Skin may start to blister",
                "Swelling of the affected area",
                "Headache, fever and fatigue",
                "Severe cases may cause dizziness and sickness"
            ],
            accentColor: .orange,
            warningNote: "Severe sunburn with blistering requires medical attention"
        )
    }
} 
#Preview {  
    NavigationStack {
        SunburnGuidanceView()
    }
}
