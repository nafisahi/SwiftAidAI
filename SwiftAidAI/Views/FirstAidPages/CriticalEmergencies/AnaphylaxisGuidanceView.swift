import SwiftUI

struct AnaphylaxisStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct AnaphylaxisGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        AnaphylaxisStep(
            number: 1,
            title: "Check for Auto-Injector",
            icon: "syringe",
            instructions: [
                "Ask if they have an adrenaline auto-injector",
                "Help them use it or follow the instructions to administer it yourself",
                "Note the time of injection"
            ],
            warningNote: "Don't delay giving adrenaline - it could save their life",
            imageName: "step1"
        ),
        AnaphylaxisStep(
            number: 2,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately",
                "State that you suspect ANAPHYLAXIS",
                "Give details about any known allergies"
            ],
            warningNote: nil,
            imageName: "step2"
        ),
        AnaphylaxisStep(
            number: 3,
            title: "Position & Monitor",
            icon: "bed.double.fill",
            instructions: [
                "Help them get comfortable",
                "Lie them down with legs raised if breathing OK",
                "Sit them up if they're having breathing difficulties",
                "Monitor their breathing and level of response"
            ],
            warningNote: "If they become unresponsive, prepare to start CPR",
            imageName: "step3"
        ),
        AnaphylaxisStep(
            number: 4,
            title: "Further Treatment",
            icon: "clock.fill",
            instructions: [
                "A second dose can be given after 5 minutes if no improvement",
                "Give further doses at 5-minute intervals if symptoms return",
                "Keep any used auto-injectors to give to emergency services"
            ],
            warningNote: "Always monitor for deterioration even after giving adrenaline",
            imageName: "step1"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AnaphylaxisIntroCard()
                AnaphylaxisSymptomsCard()
                
                ForEach(steps) { step in
                    AnaphylaxisStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Anaphylaxis")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AnaphylaxisIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is Anaphylaxis?")
                .font(.title2)
                .bold()
            
            Text("Anaphylaxis is a severe, life-threatening allergic reaction that develops rapidly after exposure to triggers like bee stings, foods (nuts), medicines (penicillin), or latex. It affects the whole body and requires immediate emergency treatment.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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

struct AnaphylaxisSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Mild/Moderate Signs:",
                "• Red, itchy rash or raised skin (hives), especially on face/neck",
                "• Red, itchy, watery eyes",
                "• Swelling of hands, feet, or face",
                "• Abdominal pain, vomiting, or diarrhea",
                "Severe Signs:",
                "• Difficulty breathing with wheezing",
                "• Swelling of tongue and throat",
                "• Confusion and agitation",
                "• Signs of shock leading to collapse"
            ],
            accentColor: .orange,
            warningNote: "Severe symptoms can develop rapidly - act quickly"
        )
    }
}

struct AnaphylaxisStepCard: View {
    let step: AnaphylaxisStep
    @Binding var completedSteps: Set<String>
    @State private var secondDoseTimeRemaining = 300 // Timer for second dose
    @State private var secondDoseTimerRunning = false
    @State private var furtherDoseTimeRemaining = 300 // Separate timer for further doses
    @State private var furtherDoseTimerRunning = false
    @State private var showingCPR = false
    @State private var injectionTime: Date? // Add this to store injection time
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Add helper function to format time
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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
                
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            
            // Image if present
            if let uiImage = UIImage(named: step.imageName ?? "") {
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
                        CheckboxRow(
                            text: instruction,
                            isChecked: completedSteps.contains(instruction),
                            action: {
                                if completedSteps.contains(instruction) {
                                    completedSteps.remove(instruction)
                                    if instruction.contains("note time of injection") {
                                        injectionTime = nil
                                    }
                                } else {
                                    completedSteps.insert(instruction)
                                    if instruction.contains("note time of injection") {
                                        injectionTime = Date()
                                    }
                                }
                            }
                        )
                        
                        // Show time immediately after the checkbox for injection time instruction
                        if instruction.contains("note time of injection") && completedSteps.contains(instruction) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                Text("Injection given at \(formatTime(Date()))")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                            }
                            .padding(.leading, 28)
                            .animation(.easeIn, value: completedSteps.contains(instruction))
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
        .sheet(isPresented: $showingCPR) {
            NavigationStack {
                CPRGuidanceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingCPR = false
                    })
            }
        }
        .onReceive(timer) { _ in
            // Update second dose timer
            if secondDoseTimerRunning && secondDoseTimeRemaining > 0 {
                secondDoseTimeRemaining -= 1
            }
            
            // Update further dose timer
            if furtherDoseTimerRunning && furtherDoseTimeRemaining > 0 {
                furtherDoseTimeRemaining -= 1
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnaphylaxisGuidanceView()
    }
} 
