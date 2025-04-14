import SwiftUI
import Combine

struct SprainStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct SprainsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        SprainStep(
            number: 1,
            title: "Rest (R)",
            icon: "bed.double.fill",
            instructions: [
                "Help them to sit or lie down",
                "Support the injured part in a comfortable position",
                "Keep the injured area raised if possible"
            ],
            warningNote: "Do not force movement if it causes pain",
            imageName: "sprain-1"
        ),
        
        SprainStep(
            number: 2,
            title: "Ice (I)",
            icon: "snowflake",
            instructions: [
                "Apply an ice pack or cold compress",
                "Wrap frozen items in a clean tea towel - never apply directly to skin",
                "Hold in place for up to 20 minutes"
            ],
            warningNote: "Do not leave ice on for more than 20 minutes as this can cause tissue damage",
            imageName: "sprain-2"
        ),
        
        SprainStep(
            number: 3,
            title: "Comfortable Support (C)",
            icon: "hand.raised.fill",
            instructions: [
                "Use soft padding to support the injury",
                "Offer pain relief if available:",
                "• Paracetamol",
                "• Ibuprofen",
                "Never give aspirin to anyone under 16 years old"
            ],
            warningNote: "Check for any medication allergies before offering pain relief",
            imageName: "sprain-3"
        ),
        
        SprainStep(
            number: 4,
            title: "Elevate (E)",
            icon: "arrow.up.circle.fill",
            instructions: [
                "Support the injury in an elevated position",
                "Use pillows or cushions underneath",
                "This helps minimize swelling and bruising",
                "If pain is severe or they cannot move the injured part, call 999 or 112"
            ],
            warningNote: "Seek medical advice if the pain is severe or movement is significantly restricted",
            imageName: "sprain-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SprainIntroCard()
                SprainSymptomsCard()
                
                ForEach(steps) { step in
                    SprainStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Sprains and Strains")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SprainIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are sprains and strains?")
                .font(.title2)
                .bold()
            
            Text("A sprain is an injury to a ligament (tissue that connects bones), while a strain affects muscles or tendons. Both can cause pain, swelling, and restricted movement. The RICE method (Rest, Ice, Comfortable support, Elevate) helps manage these injuries.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.6, green: 0.2, blue: 0.8).opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct SprainSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Look for:",
                "• Pain and tenderness in the affected area",
                "• Swelling and bruising",
                "• Difficulty moving the injured area, especially if it's a joint"
            ],
            accentColor: Color(red: 0.6, green: 0.2, blue: 0.8),
            warningNote: "If the pain is severe or they cannot move the injured part, seek medical advice"
        )
    }
}

struct SprainStepCard: View {
    let step: SprainStep
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
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    private func isHeaderInstruction(_ instruction: String) -> Bool {
        instruction == "Look for:" || instruction.hasSuffix(":") || instruction == "Offer pain relief if available:"
    }
    
    private func isMedicationOption(_ instruction: String) -> Bool {
        instruction.hasPrefix("•") && (instruction.contains("Paracetamol") || instruction.contains("Ibuprofen"))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.2, blue: 0.8))
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
                        .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.8))
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
                    if isHeaderInstruction(instruction) {
                        Text(instruction)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.bottom, 4)
                    } else if isMedicationOption(instruction) {
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.leading, 16)
                    } else {
                        CheckboxRow(
                            text: instruction,
                            isChecked: completedSteps.contains(instruction),
                            action: {
                                if completedSteps.contains(instruction) {
                                    completedSteps.remove(instruction)
                                    // If unchecking the ice instruction, hide timer
                                    if instruction.contains("Hold in place for up to 20 minutes") {
                                        showTimer = false
                                        stopTimer()
                                    }
                                } else {
                                    completedSteps.insert(instruction)
                                    // If checking the ice instruction, show timer
                                    if instruction.contains("Hold in place for up to 20 minutes") {
                                        showTimer = true
                                        startTimer()
                                    }
                                }
                            }
                        )
                        .padding(.leading, instruction.hasPrefix("•") ? 16 : 0)
                        
                        // Show timer after the ice instruction if checked
                        if instruction.contains("Hold in place for up to 20 minutes") && showTimer {
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
                                timerColor: Color(red: 0.6, green: 0.2, blue: 0.8),
                                labelText: "Ice Timer: "
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
                    
                    if hasEmergencyNumbers(instruction) {
                        SharedEmergencyCallButtons()
                            .padding(.leading, 28)
                            .padding(.top, 4)
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
                .stroke(Color(red: 0.6, green: 0.2, blue: 0.8).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SprainsGuidanceView()
    }
} 