import SwiftUI
import Combine

struct SevereBurnStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct SevereBurnStepCard: View {
    let step: SevereBurnStep
    @Binding var completedSteps: Set<String>
    
    // States for timer functionality
    @State private var showTimer = false
    @State private var timeRemaining = 1200 // 20 minutes
    @State private var timerIsRunning = false
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    private var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timeRemaining = 1200 // Reset to 20 minutes
        timer = Timer.publish(every: 1, on: .main, in: .common)
        timerCancellable = timer.connect()
        timerIsRunning = true
    }
    
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
                                        if instruction.contains("Start cooling the burn immediately with cool running water") {
                                            showTimer = false
                                            stopTimer()
                                        }
                                    } else {
                                        completedSteps.insert(instruction)
                                        if instruction.contains("Start cooling the burn immediately with cool running water") {
                                            showTimer = true
                                            startTimer()
                                        }
                                    }
                                }
                            
                            Text(instruction)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Show timer for cooling instruction
                        if instruction.contains("Start cooling the burn immediately with cool running water") && showTimer {
                            SharedTimerView(
                                timeRemaining: $timeRemaining,
                                timeRemainingFormatted: timeRemainingFormatted,
                                timerIsRunning: $timerIsRunning,
                                onStart: { startTimer() },
                                onStop: { stopTimer() },
                                onReset: {
                                    stopTimer()
                                    timeRemaining = 1200
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
                        
                        // Show emergency call buttons if instruction mentions emergency numbers
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

struct SevereBurnsGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    let steps = [
        SevereBurnStep(
            number: 1,
            title: "Cool the Burn",
            icon: "drop.fill",
            instructions: [
                "Start cooling the burn immediately with cool running water",
                "Help casualty sit or lie down",
                "Keep burnt area from touching the ground",
                "Continue cooling for at least 20 minutes"
            ],
            warningNote: "Do not over-cool the casualty - this could cause dangerous hypothermia",
            imageName: "severe-1"
        ),
        SevereBurnStep(
            number: 2,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help",
                "If possible, ask someone else to call",
                "Continue cooling while waiting for help"
            ],
            warningNote: nil,
            imageName: "severe-2"
        ),
        SevereBurnStep(
            number: 3,
            title: "Remove Restrictions",
            icon: "hand.raised.fill",
            instructions: [
                "Carefully remove jewellery, watches, belts, shoes",
                "Remove any burnt clothing if not stuck to skin",
                "Have someone help while you continue cooling"
            ],
            warningNote: "Do not remove clothing stuck to the burn",
            imageName: "severe-3"
        ),
        SevereBurnStep(
            number: 4,
            title: "Cover the Burn",
            icon: "bandage.fill",
            instructions: [
                "Once cooled, cover loosely with cling film lengthways",
                "Discard first two turns of cling film",
                "For hands/feet, use clean plastic bag",
                "Alternative: use sterile dressing or non-fluffy material"
            ],
            warningNote: "Do not wrap cling film around the burn - it needs space to swell",
            imageName: "severe-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SevereBurnIntroCard()
                
                ForEach(steps) { step in
                    SevereBurnStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Severe Burns")
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
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

struct SevereBurnIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a Severe Burn?")
                .font(.title2)
                .bold()
            
            Text("Burns and scalds are caused by damage to the skin when it comes in contact with heat. Your priority is to cool the burn as quickly as possible. If someone has a severe burn they may develop shock which is a life-threatening condition.")
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

struct SevereBurnSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Severe pain in the burn area",
                "Red or peeling skin",
                "Blisters",
                "White or charred skin",
                "Signs of shock may develop"
            ],
            accentColor: .orange,
            warningNote: "Severe burns can be life-threatening and require immediate medical attention"
        )
    }
} 

#Preview {
    NavigationStack {
        SevereBurnsGuidanceView()
    }
}
