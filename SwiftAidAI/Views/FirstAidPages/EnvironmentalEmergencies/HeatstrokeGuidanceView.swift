import SwiftUI

// Data structure for heatstroke step information
struct HeatstrokeStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for heatstroke guidance with instructions
struct HeatstrokeGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of steps for managing heatstroke
    let steps = [
        HeatstrokeStep(
            number: 1,
            title: "Move to Cool Place",
            icon: "sun.min.fill",
            instructions: [
                "Move them to a cool, shaded place.",
                "Remove their outer clothing if possible.",
                "If they are conscious, give them water to drink."
            ],
            warningNote: nil,
            imageName: nil
        ),
        HeatstrokeStep(
            number: 2,
            title: "Call Emergency Services",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 immediately.",
                "Explain symptoms and follow their instructions.",
            
            ],
            warningNote: "Heatstroke is a life-threatening condition",
            imageName: nil
        ),
        HeatstrokeStep(
            number: 3,
            title: "Cool Them Down",
            icon: "thermometer.snowflake",
            instructions: [
                "Wrap them in a cool, wet sheet.",
                "Fan them or sponge with cold water.",
                "Place cold packs in armpits and around neck if available.",
                "Replace wet sheet with dry one once temperature normalizes."
            ],
            warningNote: "If temperature rises again, repeat cooling process.",
            imageName: nil
        ),
        HeatstrokeStep(
            number: 4,
            title: "Monitor Condition",
            icon: "heart.text.square.fill",
            instructions: [
                "Check their temperature regularly.",
                "Monitor breathing and pulse.",
                "Watch their level of response.",
            
            ],
            warningNote: "If they become unresponsive, start CPR immediately.",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining heatstroke
                HeatstrokeIntroductionCard()
                
                // Display each heatstroke step
                ForEach(steps) { step in
                    HeatstrokeStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
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

// Introduction card explaining what heatstroke is and its symptoms
struct HeatstrokeIntroductionCard: View {
    // Main container for introduction content
    var body: some View {
        VStack(spacing: 16) {
            // What is Heatstroke explanation
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Heatstroke?")
                    .font(.title2)
                    .bold()
                
                Text("Heatstroke is caused by a failure of the 'thermostat' in the brain which regulates body temperature. The body becomes unable to cool down, leading to dangerously high temperatures above 40°C.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.teal.opacity(0.1))
            )
            
            // Symptoms card showing signs of heatstroke
            HeatstrokeSymptomsCard()
        }
        .padding(.horizontal)
    }
}

// Card showing heatstroke symptoms and signs
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
                "Body temperature above 40°C"
            ],
            accentColor: .teal,
            warningNote: nil
        )
    }
}

// Card component for each heatstroke step with instructions and completion tracking
struct HeatstrokeStepCard: View {
    let step: HeatstrokeStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
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
                        .fill(Color.teal)
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
                        .foregroundColor(.teal)
                }
            }
            
            // Step image if available
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section with checkboxes and emergency buttons
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        // Standard checkbox row for instructions
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
                        
                        // Show emergency call buttons if instruction contains emergency numbers
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
                
                // Warning note section with emergency call buttons if needed
                if let warning = step.warningNote {
                    if warning.contains("CPR") {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.subheadline)
                            
                            (Text("If they become unresponsive, ")
                                .foregroundColor(.orange) +
                            Text("start CPR")
                                .foregroundColor(.teal)
                                .underline())
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 4)
                        .onTapGesture {
                            showingCPR = true
                        }
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
        // Card styling with background, shadow and border
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
        // Sheet presentation for CPR guidance if needed
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
} 