import SwiftUI
import Combine

// Data structure for hyperventilation step information
struct HyperventilationStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for hyperventilation guidance with instructions
struct HyperventilationGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Define the sequence of steps for managing hyperventilation
    let steps = [
        HyperventilationStep(
            number: 1,
            title: "Identify Signs",
            icon: "checklist",
            instructions: [
                "Look for:",
                "• Abnormally fast or deep breathing",
                "• Anxiety",
                "• A fast pulse-rate",
                "Later signs may include:",
                "• Dizziness or feeling faint",
                "• Trembling, sweating and dry mouth",
                "• Tingling and cramps in hands, feet and around the mouth"
            ],
            warningNote: nil,
            imageName: nil
        ),
        HyperventilationStep(
            number: 2,
            title: "Immediate Response",
            icon: "person.fill",
            instructions: [
                "Take them to a quiet place",
                "Ask any bystanders to leave",
                "Give the casualty space",
                "Try to reassure them and be kind"
            ],
            warningNote: "Do not advise the casualty to breathe into a paper bag as this could make the condition worse",
            imageName: "sit"
        ),
        HyperventilationStep(
            number: 3,
            title: "Further Action",
            icon: "cross.case.fill",
            instructions: [
                "Encourage them to seek medical advice",
                "Explain that this will help them learn how to prevent and control future attacks"
            ],
            warningNote: "It is rare for children to suffer from hyperventilation, so you should try looking for other causes",
            imageName: "help"
        ),
        HyperventilationStep(
            number: 4,
            title: "Emergency Response",
            icon: "phone.fill",
            instructions: [
                "Call 999 or 112 if:",
                "• They do not seem to improve",
                "• You are worried about their condition"
            ],
            warningNote: nil,
            imageName: "call"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining hyperventilation
                HyperventilationIntroCard()
                
                // Display each hyperventilation step
                ForEach(steps) { step in
                    HyperventilationStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Hyperventilation")
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

// Introduction card explaining what hyperventilation is
struct HyperventilationIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is hyperventilation?")
                .font(.title2)
                .bold()
            
            Text("Hyperventilation is unnatural, fast or deep breathing, normally caused by anxiety, experiencing an emotional upset or a history of panic attacks.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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

// Card component for each hyperventilation step with instructions and completion tracking
struct HyperventilationStepCard: View {
    let step: HyperventilationStep
    @Binding var completedSteps: Set<String>
    
    // Check if text contains emergency numbers
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    // Check if instruction is a header or bullet point
    private func isHeaderOrBulletPoint(_ instruction: String) -> Bool {
        instruction.hasSuffix(":") || instruction.hasPrefix("-")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
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
            
            // Instructions section with special handling for headers and bullet points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    if instruction.hasPrefix("•") {
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.leading, 28)
                            .padding(.vertical, 2)
                    } else if instruction.hasSuffix(":") {
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
                
                // Add emergency call buttons if needed
                if step.instructions.contains("Call 999 or 112 if:") {
                    SharedEmergencyCallButtons()
                        .padding(.top, 12)
                }
            }
            
            // Warning note section if present
            if let warning = step.warningNote {
                WarningNote(text: warning)
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
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        HyperventilationGuidanceView()
    }
} 