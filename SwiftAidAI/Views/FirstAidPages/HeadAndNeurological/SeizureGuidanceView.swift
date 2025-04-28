import SwiftUI
import Combine

struct SeizureStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct SeizureGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    @Environment(\.dismiss) private var dismiss
    
    let steps = [
        SeizureStep(
            number: 1,
            title: "Protect the Area",
            icon: "shield.fill",
            instructions: [
                "Ask bystanders to step back",
                "Help protect the casualty's privacy",
                "Clear away dangerous objects",
                "Make a note of seizure start time"
            ],
            warningNote: "Do not restrain the casualty or move them unless in immediate danger. Do not put anything in their mouth.",
            imageName: "seizure-1"
        ),
        SeizureStep(
            number: 2,
            title: "Protect Their Head",
            icon: "brain.head.profile",
            instructions: [
                "Place soft padding under their head",
                "Use a rolled-up towel if available",
                "Loosen any clothing around their neck"
            ],
            warningNote: nil,
            imageName: "seizure-2"
        ),
        SeizureStep(
            number: 3,
            title: "After Movements Stop",
            icon: "lungs.fill",
            instructions: [
                "Open their airway",
                "Check their breathing",
                "If breathing, place in recovery position"
            ],
            warningNote: "If they become unresponsive, prepare to start CPR immediately",
            imageName: "seizure-3"
        ),
        SeizureStep(
            number: 4,
            title: "Monitor Response",
            icon: "eye.fill",
            instructions: [
                "Monitor their level of response",
                "Note how long the seizure lasted",
                "Allow 15-30 minutes for recovery"
            ],
            warningNote: "Check for alert bracelet or care plan with specific instructions",
            imageName: "seizure-4"
        ),
        SeizureStep(
            number: 5,
            title: "When to Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 if:",
                "• It's their first seizure",
                "• They have repeated seizures",
                "• Cause is unknown",
                "• Seizure lasts over 5 minutes",
                "• Unresponsive for over 10 minutes after seizure",
                "• They have other injuries",
                "• Breathing is not normal"
            ],
            warningNote: nil,
            imageName: "seizure-5"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SeizureIntroCard()
                
                ForEach(steps) { step in
                    SeizureStepCard(step: step, completedSteps: $completedSteps, showingCPR: $showingCPR)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Seizures/Epilepsy")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                        Text("Back")
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                    }
                }
            }
        }
        .sheet(isPresented: $showingCPR) {
            NavigationStack {
                CPRGuidanceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingCPR = false
                    })
            }
        }
    }
}

struct SeizureIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are seizures and what causes them?")
                .font(.title2)
                .bold()
            
            Text("Seizures (convulsions or fits) can be caused by epilepsy, sleep deprivation, stress, head injuries, alcohol, lack of oxygen, drugs, extreme temperatures, flashing lights, or low blood glucose. Epilepsy causes repeated, sudden seizures.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.3, green: 0.3, blue: 0.8).opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct SeizureStepCard: View {
    let step: SeizureStep
    @Binding var completedSteps: Set<String>
    @Binding var showingCPR: Bool
    
    // States for timer functionality
    @State private var timeRemaining = 300 // 5 minutes in seconds for seizure duration
    @State private var timerIsRunning = false
    @State private var showTimer = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    private func isBulletPoint(_ text: String) -> Bool {
        text.hasPrefix("•")
    }
    
    // Format remaining time as MM:SS
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the timer
    private func startTimer() {
        timeRemaining = 300 // Reset to 5 minutes
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
                        .fill(Color(red: 0.3, green: 0.3, blue: 0.8))
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
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                }
            }
            
            // Add the image if available
            if let imageName = step.imageName {
                Image(imageName)
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
                        if isBulletPoint(instruction) {
                            Text(instruction)
                                .padding(.leading, 28)
                        } else {
                            CheckboxRow(
                                text: instruction,
                                isChecked: completedSteps.contains(instruction),
                                action: {
                                    if completedSteps.contains(instruction) {
                                        completedSteps.remove(instruction)
                                        if instruction.contains("Make a note of seizure start time") {
                                            showTimer = false
                                            stopTimer()
                                        }
                                    } else {
                                        completedSteps.insert(instruction)
                                        if instruction.contains("Make a note of seizure start time") {
                                            showTimer = true
                                            startTimer()
                                        }
                                    }
                                }
                            )
                        }
                        
                        // Show timer after noting seizure start time
                        if instruction.contains("Make a note of seizure start time") && showTimer {
                            SharedTimerView(
                                timeRemaining: $timeRemaining,
                                timeRemainingFormatted: timeRemainingFormatted,
                                timerIsRunning: $timerIsRunning,
                                onStart: { startTimer() },
                                onStop: { stopTimer() },
                                onReset: {
                                    stopTimer()
                                    timeRemaining = 300  // Reset to 5 minutes
                                    startTimer()
                                },
                                timerColor: Color(red: 0.3, green: 0.3, blue: 0.8),
                                labelText: "Seizure Duration: "
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
                
                if let warning = step.warningNote {
                    if warning.contains("CPR") {
                        CPRWarningNote(showingCPR: $showingCPR)
                    } else {
                        WarningNote(text: warning)
                    }
                }
                
                // Add emergency call buttons at the end if the step contains emergency numbers
                if step.instructions.joined().contains("999") || step.instructions.joined().contains("112") {
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
                .stroke(Color(red: 0.3, green: 0.3, blue: 0.8).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingCPR) {
            NavigationStack {
                CPRGuidanceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingCPR = false
                    })
            }
        }
    }
}

#Preview {
    NavigationStack {
        SeizureGuidanceView()
    }
} 