import SwiftUI
struct ShockStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String
}

struct ShockGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        ShockStep(
            number: 1,
            title: "Treat Primary Cause",
            icon: "cross.fill",
            instructions: [
                "Check for and treat visible causes of shock",
                "Look for severe bleeding",
                "Check for signs of heart problems",
                "Look for signs of dehydration",
                "Check for allergic reactions"
            ],
            warningNote: "Shock can rapidly become life-threatening - act quickly",
            imageName: "shock1"
        ),
        ShockStep(
            number: 2,
            title: "Position the Casualty",
            icon: "person.fill",
            instructions: [
                "Help them lie down flat",
                "Raise and support their legs on a chair",
                "Place them on a rug or blanket if available"
            ],
            warningNote: "This position helps improve blood supply to vital organs",
            imageName: "shock2"
        ),
        ShockStep(
            number: 3,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help",
                "Tell them you suspect shock",
                "Explain the likely cause if known"
            ],
            warningNote: nil,
            imageName: "shock3"
        ),
        ShockStep(
            number: 4,
            title: "Loosen Clothing",
            icon: "person.crop.circle",
            instructions: [
                "Loosen any tight clothing around the neck",
                "Loosen clothing around the chest",
                "Loosen clothing around the waist"
            ],
            warningNote: "This helps maintain blood circulation",
            imageName: "shock 4"
        ),
        ShockStep(
            number: 5,
            title: "Keep Warm",
            icon: "thermometer.sun.fill",
            instructions: [
                "Cover them with a coat or blanket",
                "Keep them protected from the cold",
                "Maintain a comfortable temperature"
            ],
            warningNote: "Avoid overheating the casualty",
            imageName: "shock-step-5"
        ),
        ShockStep(
            number: 6,
            title: "Monitor and Reassure",
            icon: "heart.text.square.fill",
            instructions: [
                "Keep checking their level of response",
                "Reassure them and keep them calm",
                "Try to reduce fear and pain"
            ],
            warningNote: "If they become unresponsive, prepare to start CPR",
            imageName: "shock-final-step"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ShockIntroductionCard()
                
                ForEach(steps) { step in
                    ShockStepCard(step: step, completedSteps: $completedSteps)
                }
                
                ShockSymptomsCard()
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Shock")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ShockIntroductionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Shock?")
                    .font(.title2)
                    .bold()
                
                Text("Shock is a life-threatening condition where vital organs don't receive enough blood flow. It can be caused by severe bleeding, heart problems, dehydration, allergic reactions, spinal injuries, or severe infections.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pink.opacity(0.1))
            )
            
            ShockSymptomsCard()
        }
        .padding(.horizontal)
    }
}

struct ShockSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Warning Signs of Shock",
            symptoms: [
                "Pale, cold, clammy skin",
                "Fast, shallow breathing",
                "Weak, rapid pulse",
                "Grey-blue lips or extremities",
                "Nausea and possible vomiting",
                "Restlessness or aggression",
                "Yawning and gasping for air"
            ],
            accentColor: .pink,
            warningNote: "These signs may develop rapidly - act quickly"
        )
    }
}

struct ShockStepCard: View {
    let step: ShockStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StepHeader(step: step)
            
            // Add the image if present
            if let uiImage = UIImage(named: step.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section
            if step.number == 3 {
                EmergencyInstructions(
                    instructions: step.instructions,
                    completedSteps: $completedSteps
                )
            } else {
                RegularInstructions(
                    instructions: step.instructions,
                    completedSteps: $completedSteps
                )
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

// Break down into smaller components
private struct StepHeader: View {
    let step: ShockStep
    
    var body: some View {
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
    }
}

private struct EmergencyInstructions: View {
    let instructions: [String]
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(instructions, id: \.self) { instruction in
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
}

private struct RegularInstructions: View {
    let instructions: [String]
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(instructions, id: \.self) { instruction in
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
}

#Preview {
    NavigationStack {
        ShockGuidanceView()
    }
}
