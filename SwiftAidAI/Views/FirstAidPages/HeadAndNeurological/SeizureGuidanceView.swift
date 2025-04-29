import SwiftUI
import Combine

// Data structure for seizure step information
struct SeizureStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for seizure guidance with instructions
struct SeizureGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    @Environment(\.dismiss) private var dismiss
    
    // Array of steps for seizure first aid
    let steps = [
        SeizureStep(
            number: 1,
            title: "Protect the Area",
            icon: "shield.fill",
            instructions: [
                "Ask bystanders to step back.",
                "Help protect the casualty's privacy.",
                "Clear away dangerous objects.",
                "Make a note of seizure start time."
            ],
            warningNote: "Do not restrain the casualty or move them unless in immediate danger. Do not put anything in their mouth.",
            imageName: "seizure-1"
        ),
        SeizureStep(
            number: 2,
            title: "Protect Their Head",
            icon: "brain.head.profile",
            instructions: [
                "Place soft padding under their head.",
                "Use a rolled-up towel if available.",
                "Loosen any clothing around their neck."
            ],
            warningNote: nil,
            imageName: "seizure-2"
        ),
        SeizureStep(
            number: 3,
            title: "After Movements Stop",
            icon: "lungs.fill",
            instructions: [
                "Open their airway.",
                "Check their breathing.",
                "If breathing, place in recovery position."
            ],
            warningNote: "If they become unresponsive, prepare to start CPR immediately",
            imageName: "seizure-3"
        ),
        SeizureStep(
            number: 4,
            title: "Monitor Response",
            icon: "eye.fill",
            instructions: [
                "Monitor their level of response.",
                "Note how long the seizure lasted.",
                "Allow 15-30 minutes for recovery."
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
                // Introduction card explaining seizures
                SeizureIntroCard()
                
                // Display each seizure step card
                ForEach(steps) { step in
                    SeizureStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
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
            CPRGuidanceView()
                .presentationDragIndicator(.visible)
        }
    }
}

// Introduction card explaining seizures and their causes
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

// Card component for each seizure step with instructions and completion tracking
struct SeizureStepCard: View {
    let step: SeizureStep
    @Binding var completedSteps: Set<String>
    @State private var seizureStartTime: Date? = nil
    @State private var showingCPR = false
    
    // Format time for seizure start display
    private func formatSeizureStartTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
    
    // Helper function to check if text contains emergency numbers
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    // Helper function to check if text is a bullet point
    private func isBulletPoint(_ text: String) -> Bool {
        text.hasPrefix("•")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
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
            
            // Display step image if available
            if let imageName = step.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions list with checkboxes and bullet points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if isBulletPoint(instruction) {
                            Text(instruction)
                                .font(.subheadline)
                                .padding(.leading, 28)
                        } else {
                            CheckboxRow(
                                text: instruction,
                                isChecked: completedSteps.contains(instruction),
                                action: {
                                    if completedSteps.contains(instruction) {
                                        completedSteps.remove(instruction)
                                        if instruction.contains("Make a note of seizure start time") {
                                            seizureStartTime = nil
                                        }
                                    } else {
                                        completedSteps.insert(instruction)
                                        if instruction.contains("Make a note of seizure start time") {
                                            seizureStartTime = Date()
                                        }
                                    }
                                }
                            )
                            
                            // Display seizure start time when instruction is checked
                            if instruction.contains("Make a note of seizure start time") && 
                               completedSteps.contains(instruction) && 
                               seizureStartTime != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                        .font(.system(size: 16))
                                    
                                    Text("Seizure started at \(formatSeizureStartTime(seizureStartTime!))")
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                        .fontWeight(.medium)
                                }
                                .padding(.leading, 28)
                                .padding(.top, 4)
                                .transition(.slide)
                            }
                        }
                    }
                }
                
                // Warning note with CPR link or standard warning
                if let warning = step.warningNote {
                    if warning.contains("CPR") {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.subheadline)
                            
                            Text("If they become unresponsive, prepare to ")
                                .foregroundColor(.orange)
                                .font(.subheadline) +
                            Text("start CPR")
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                .font(.subheadline)
                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 28)
                        .padding(.top, 4)
                        .onTapGesture {
                            showingCPR = true
                        }
                    } else {
                        WarningNote(text: warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Add emergency call buttons at the end of step 5
                if step.number == 5 {
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
            CPRGuidanceView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        SeizureGuidanceView()
    }
} 
