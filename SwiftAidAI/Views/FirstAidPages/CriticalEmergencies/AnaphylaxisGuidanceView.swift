import SwiftUI
import Combine

// Data structure for anaphylaxis step information
struct AnaphylaxisStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for anaphylaxis guidance with instructions
struct AnaphylaxisGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        AnaphylaxisStep(
            number: 1,
            title: "Check for Auto-Injector",
            icon: "syringe",
            instructions: [
                "Ask if they have an adrenaline auto-injector.",
                "Help them use it or follow the instructions to administer it yourself.",
                "Note the time of injection."
            ],
            warningNote: "Don't delay giving adrenaline - it could save their life.",
            imageName: "step1"
        ),
        AnaphylaxisStep(
            number: 2,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately.",
                "State that you suspect anaphylaxis.",
                "Give details about any known allergies."
            ],
            warningNote: nil,
            imageName: "step2"
        ),
        AnaphylaxisStep(
            number: 3,
            title: "Position & Monitor",
            icon: "bed.double.fill",
            instructions: [
                "Help them get comfortable.",
                "Lie them down with legs raised if breathing OK.",
                "Sit them up if they're having breathing difficulties.",
                "Monitor their breathing and level of response."
            ],
            warningNote: "If they become unresponsive, prepare to start CPR",
            imageName: "step3"
        ),
        AnaphylaxisStep(
            number: 4,
            title: "Further Treatment",
            icon: "clock.fill",
            instructions: [
                "A second dose can be given after 5 minutes if no improvement.",
                "Give further doses at 5-minute intervals if symptoms return.",
                "Keep any used auto-injectors to give to emergency services."
            ],
            warningNote: "Always monitor for deterioration even after giving adrenaline",
            imageName: "step1"
        )
    ]
    
    // Main view body showing anaphylaxis guidance steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining anaphylaxis
                AnaphylaxisIntroCard()
                // Card showing anaphylaxis symptoms
                AnaphylaxisSymptomsCard()
                
                // Display each anaphylaxis step
                ForEach(steps) { step in
                    AnaphylaxisStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Anaphylaxis")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// Introduction card explaining what anaphylaxis is
struct AnaphylaxisIntroCard: View {
    // Main container for introduction content
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
                .fill(Color.red.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card showing anaphylaxis symptoms and signs
struct AnaphylaxisSymptomsCard: View {
    // Main container for symptoms content
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Mild/Moderate Signs:",
                "Red, itchy rash or raised skin (hives), especially on face/neck",
                "Red, itchy, watery eyes",
                "Swelling of hands, feet, or face",
                "Abdominal pain, vomiting, or diarrhea",
                "Severe Signs:",
                "Difficulty breathing with wheezing",
                "Swelling of tongue and throat",
                "Confusion and agitation",
                "Signs of shock leading to collapse"
            ],
            accentColor: .red,
            warningNote: "Severe symptoms can develop rapidly - act quickly."
        )
    }
}

// Card component for each anaphylaxis step with instructions and completion tracking
struct AnaphylaxisStepCard: View {
    let step: AnaphylaxisStep
    @Binding var completedSteps: Set<String>
    @State private var injectionTime: Date? = nil
    @State private var showingCPR = false
    
    // Format time for injection display
    private func formatInjectionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    // Main container for step content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Step title and icon
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            
            // Step image if available
            if let uiImage = UIImage(named: step.imageName ?? "") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section containing checkboxes for each step
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        CheckboxRow(
                            text: instruction,
                            isChecked: completedSteps.contains(instruction),
                            action: {
                                if completedSteps.contains(instruction) {
                                    completedSteps.remove(instruction)
                                    if instruction.lowercased().contains("note") && instruction.lowercased().contains("time") {
                                        injectionTime = nil
                                    }
                                } else {
                                    completedSteps.insert(instruction)
                                    if instruction.lowercased().contains("note") && instruction.lowercased().contains("time") {
                                        injectionTime = Date()
                                    }
                                }
                            }
                        )
                        
                        if instruction.lowercased().contains("note") && 
                           instruction.lowercased().contains("time") && 
                           completedSteps.contains(instruction) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                
                                Text("Adrenaline administered at \(formatInjectionTime(injectionTime ?? Date()))")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                            }
                            .padding(.leading, 28)
                            .padding(.top, 4)
                            .transition(.slide)
                        }
                    }
                }
            }
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    CPRWarningNote(showingCPR: $showingCPR)
                } else {
                    WarningNote(text: warning)
                    if hasEmergencyNumbers(warning) {
                        SharedEmergencyCallButtons()
                            .padding(.top, 4)
                    }
                }
            }
        }
        // Card styling with background, shadow and border
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        // Sheet presentation for CPR guidance if needed
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        AnaphylaxisGuidanceView()
    }
} 
