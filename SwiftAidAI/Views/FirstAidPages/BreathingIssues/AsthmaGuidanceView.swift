import SwiftUI
import Combine

struct AsthmaStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct AsthmaGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    let steps = [
        AsthmaStep(
            number: 1,
            title: "Initial Response",
            icon: "lungs.fill",
            instructions: [
                "Help them sit in a comfortable position",
                "Keep them calm and reassure them",
                "Ask them to take their reliever inhaler (usually blue)",
                "If available, use a spacer with the inhaler"
            ],
            warningNote: "A spacer makes the inhaler more effective, especially for children",
            imageName: "sit"
        ),
        AsthmaStep(
            number: 2,
            title: "Monitor Response",
            icon: "clock.fill",
            instructions: [
                "Wait a few minutes to see if symptoms improve",
                "If no improvement, this may be a severe attack",
                "Ask them to take one puff every 30-60 seconds",
                "Continue until they have taken 10 puffs"
            ],
            warningNote: "If they have no inhaler, call 999 or 112 immediately",
            imageName: "asthma"
        ),
        AsthmaStep(
            number: 3,
            title: "Emergency Response",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 if:",
                "- The attack is severe or getting worse",
                "- They are becoming exhausted",
                "- This is their first attack",
                "- They have no inhaler"
            ],
            warningNote: "If ambulance hasn't arrived in 15 minutes, repeat the 10 puffs - start timer",
            imageName: "call"
        ),
        AsthmaStep(
            number: 4,
            title: "Ongoing Monitoring",
            icon: "heart.text.square.fill",
            instructions: [
                "Monitor their breathing and level of response",
                "If symptoms improve without calling 999, advise them to see their GP urgently",
                "Stay with them until they fully recover"
            ],
            warningNote: "If they become unresponsive, prepare to start CPR",
            imageName: "help"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsthmaIntroductionCard()
                
                ForEach(steps) { step in
                    AsthmaStepCard(step: step, completedSteps: $completedSteps)
                }
                
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

struct AsthmaStepCard: View {
    let step: AsthmaStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    // Add timer states
    @State private var showTimer = false
    @State private var timeRemaining = 900 // 15 minutes in seconds
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
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
        timeRemaining = 900 // Reset to 15 minutes
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
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if isEmergencyCallList(instruction) {
                            CheckboxRow(
                                text: instruction,
                                isChecked: completedSteps.contains(instruction),
                                action: {
                                    if completedSteps.contains(instruction) {
                                        completedSteps.remove(instruction)
                                        showTimer = false
                                        stopTimer()
                                    } else {
                                        completedSteps.insert(instruction)
                                        showTimer = true
                                        startTimer()
                                    }
                                }
                            )
                        } else if instruction.hasPrefix("-") {
                            Text(instruction)
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
                
                // Add emergency call buttons
                if step.instructions.contains("Call 999 or 112 if:") {
                    SharedEmergencyCallButtons()
                        .padding(.top, 12)
                }
                
                // Show timer if emergency call is checked
                if showTimer && step.number == 3 {
                    SharedTimerView(
                        timeRemaining: $timeRemaining,
                        timeRemainingFormatted: timeRemainingFormatted,
                        timerIsRunning: $timerIsRunning,
                        onStart: { startTimer() },
                        onStop: { stopTimer() },
                        onReset: {
                            stopTimer()
                            timeRemaining = 900  // Reset to 15 minutes
                            startTimer()
                        },
                        timerColor: .blue,
                        labelText: "Ambulance Timer: "
                    )
                    .padding(.top, 12)
                    .onReceive(timer) { _ in
                        if timerIsRunning && timeRemaining > 0 {
                            timeRemaining -= 1
                        } else if timeRemaining == 0 {
                            stopTimer()
                        }
                    }
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    CPRWarningNote(showingCPR: $showingCPR)
                } else if warning.contains("start timer") {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        
                        (Text("If the ambulance hasn't arrived in 15 minutes, repeat the 10 puffs -")
                            .foregroundColor(.orange) +
                        Text("start timer")
                            .foregroundColor(.blue)
                            .underline())
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                    .onTapGesture {
                        showTimer = true
                        startTimer()
                    }
                } else {
                    WarningNote(text: warning)
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
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
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
        AsthmaGuidanceView()
    }
} 