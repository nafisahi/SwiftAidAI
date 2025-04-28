import SwiftUI

struct HeatstrokeStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct HeatstrokeGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    let steps = [
        HeatstrokeStep(
            number: 1,
            title: "Move to Cool Place",
            icon: "sun.min.fill",
            instructions: [
                "Move them to a cool, shaded place",
                "Remove their outer clothing if possible"
            ],
            warningNote: nil,
            imageName: nil
        ),
        HeatstrokeStep(
            number: 2,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately",
                "Explain symptoms and follow their instructions"
            ],
            warningNote: "Heatstroke is a life-threatening condition",
            imageName: nil
        ),
        HeatstrokeStep(
            number: 3,
            title: "Cool Them Down",
            icon: "thermometer.snowflake",
            instructions: [
                "Wrap them in a cool, wet sheet",
                "Fan them or sponge with cold water",
                "Place cold packs in armpits and around neck if available",
                "Replace wet sheet with dry one once temperature normalizes"
            ],
            warningNote: "If temperature rises again, repeat cooling process",
            imageName: nil
        ),
        HeatstrokeStep(
            number: 4,
            title: "Monitor Condition",
            icon: "heart.text.square.fill",
            instructions: [
                "Check their temperature regularly",
                "Monitor breathing and pulse",
                "Watch their level of response",
            
            ],
            warningNote: "If they become unresponsive, start CPR immediately",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeatstrokeIntroductionCard()
                
                ForEach(steps) { step in
                    HeatstrokeStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Heatstroke")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.teal)
                        Text("Back")
                            .foregroundColor(.teal)
                    }
                }
            }
        }
    }
}

struct HeatstrokeIntroductionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Heatstroke?")
                    .font(.title2)
                    .bold()
                
                Text("Heatstroke is caused by a failure of the 'thermostat' in the brain which regulates body temperature. The body becomes unable to cool down, leading to dangerously high temperatures above 40°C (104°F).")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.teal.opacity(0.1))
            )
            
            HeatstrokeSymptomsCard()
        }
        .padding(.horizontal)
    }
}

struct HeatstrokeSymptomsCard: View {
    var body: some View {
        SymptomsCard(
            title: "Signs and Symptoms",
            symptoms: [
                "Headache, dizziness and discomfort",
                "Restlessness, confusion or unusual behaviour",
                "Hot flushed and dry skin",
                "Fast deterioration in level of response",
                "Full bounding pulse",
                "Body temperature above 40°C (104°F)"
            ],
            accentColor: .teal,
            warningNote: "Heatstroke is a medical emergency - call 999/112"
        )
    }
}

struct HeatstrokeStepCard: View {
    let step: HeatstrokeStep
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
                        .fill(Color.teal)
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
                        .foregroundColor(.teal)
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
                    if warning.contains("CPR") || warning.contains("start CPR") {
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
                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
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