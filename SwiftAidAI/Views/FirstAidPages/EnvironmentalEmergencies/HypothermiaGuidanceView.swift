import SwiftUI

struct HypothermiaStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct HypothermiaGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    
    let steps = [
        HypothermiaStep(
            number: 1,
            title: "Move to Shelter",
            icon: "house.fill",
            instructions: [
                "Move them indoors if possible",
                "If outdoors, find a sheltered place",
                "Shield them from wind",
                "Protect them from cold ground using insulating materials"
            ],
            warningNote: nil,
            imageName: nil
        ),
        HypothermiaStep(
            number: 2,
            title: "Manage Clothing",
            icon: "tshirt.fill",
            instructions: [
                "Remove any wet clothing",
                "Replace with dry clothing or blankets",
                "Cover their head",
                "Wrap in foil survival blanket if available"
            ],
            warningNote: "Do not give away your own clothes - you must stay warm too",
            imageName: nil
        ),
        HypothermiaStep(
            number: 3,
            title: "Call for Help",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 for emergency help",
                "Stay with the casualty",
                "If in remote area, send two people for help together"
            ],
            warningNote: "Never leave the casualty alone",
            imageName: nil
        ),
        HypothermiaStep(
            number: 4,
            title: "Warm Gradually",
            icon: "thermometer.medium",
            instructions: [
                "If indoors, warm room to about 25°C (77°F)",
                "Cover with layers of blankets",
                "If alert, give warm drinks and high-energy food",
                "Monitor breathing and response level"
            ],
            warningNote: "Do not apply direct heat (hot water bottles/fires) - risk of burns. Do not give alcohol.",
            imageName: nil
        ),
        HypothermiaStep(
            number: 5,
            title: "Monitor Condition",
            icon: "heart.text.square.fill",
            instructions: [
                "Check breathing regularly",
                "Monitor level of response",
                "Watch for signs of improvement",
                "Be prepared to start CPR if they become unresponsive"
            ],
            warningNote: "If they become unresponsive, start CPR immediately",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HypothermiaIntroductionCard()
                
                ForEach(steps) { step in
                    HypothermiaStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Hypothermia")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HypothermiaIntroductionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Hypothermia?")
                    .font(.title2)
                    .bold()
                
                Text("Hypothermia occurs when body temperature drops below 35°C (95°F). Normal body temperature is around 37°C (98.6°F). This condition can become life-threatening quickly and requires immediate treatment.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
            )
            
            HypothermiaSymptomsCard()
        }
        .padding(.horizontal)
    }
}

struct HypothermiaSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Shivering, cold and pale with dry skin",
                "Unusually tired and confused",
                "Irrational behaviour",
                "Reduced level of response",
                "Slow and shallow breathing",
                "Slow and weakening pulse"
            ],
            accentColor: .blue,
            warningNote: "Hypothermia is a medical emergency - call 999/112"
        )
    }
}

struct HypothermiaStepCard: View {
    let step: HypothermiaStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                // Step Number Circle
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Title and Icon
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
                        
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
                
                if let warning = step.warningNote {
                    if warning.contains("CPR") {
                        CPRWarningNote(showingCPR: $showingCPR)
                    } else {
                        WarningNote(text: warning)
                    }
                    if hasEmergencyNumbers(warning) {
                        SharedEmergencyCallButtons()
                            .padding(.top, 4)
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
        HypothermiaGuidanceView()
    }
} 