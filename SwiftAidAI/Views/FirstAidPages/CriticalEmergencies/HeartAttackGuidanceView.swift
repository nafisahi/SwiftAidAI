import SwiftUI

struct HeartAttackStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String
}

struct HeartAttackGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        HeartAttackStep(
            number: 1,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately",
                "Tell them you suspect a heart attack",
                "Stay on the line for further instructions"
            ],
            warningNote: "Don't delay calling - early treatment is crucial",
            imageName: "heart-attack-1"
        ),
        HeartAttackStep(
            number: 2,
            title: "Position & Comfort",
            icon: "person.fill",
            instructions: [
                "Help them into a comfortable position on the floor",
                "Bend their knees for support",
                "Support their head and shoulders with cushions",
                "Keep them calm and reassured"
            ],
            warningNote: nil,
            imageName: "heart-attack-2"
        ),
        HeartAttackStep(
            number: 3,
            title: "Medication",
            icon: "pills.fill",
            instructions: [
                "Give one 300mg aspirin tablet to chew slowly",
                "Help them take their own angina medication if they have it"
            ],
            warningNote: "Do not give aspirin to anyone under 16 or allergic to it",
            imageName: "heart-attack-3"
        ),
        HeartAttackStep(
            number: 4,
            title: "Monitor",
            icon: "waveform.path.ecg",
            instructions: [
                "Keep monitoring their level of response",
                "Stay with them until help arrives",
                "Be prepared to start CPR if they become unresponsive and stop breathing normally"
            ],
            warningNote: "If they become unresponsive and not breathing normally, start CPR immediately",
            imageName: "heart-attack-5"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeartAttackIntroCard()
                HeartAttackSymptomsCard()
                
                // Steps
                ForEach(steps) { step in
                    HeartAttackStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Attribution Footer
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Heart Attack")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HeartAttackIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a Heart Attack?")
                .font(.title2)
                .bold()
            
            Text("A heart attack happens when the supply of blood to part of the heart is suddenly blocked, usually by a blood clot. You can make a full recovery following a heart attack, but this may depend on how much of the heart is affected.")
                .foregroundColor(.secondary)
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

struct HeartAttackSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Crushing pain in the centre of their chest",
                "Pain spreading to jaw and arms",
                "Breathlessness or gasping",
                "Excessive sweating",
                "Signs similar to indigestion",
                "Sudden collapse",
                "Pale skin and blue-tinted lips",
                "Rapid, weak, or irregular pulse",
                "Feeling of impending doom"
            ],
            accentColor: .red,
            warningNote: nil
        )
    }
}

struct HeartAttackStepCard: View {
    let step: HeartAttackStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red)
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
                        .foregroundColor(.red)
                }
            }
            
            // Add the image if present
            if let uiImage = UIImage(named: step.imageName) {
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
            
            // Warning note if present
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    CPRWarningNote(showingCPR: $showingCPR)
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
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
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
        HeartAttackGuidanceView()
    }
} 