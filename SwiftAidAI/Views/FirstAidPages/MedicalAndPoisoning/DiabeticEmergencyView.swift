import SwiftUI
import Combine

// Data structure for diabetic step information
struct DiabeticStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for diabetic emergency guidance with instructions
struct DiabeticEmergencyView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Define the sequence of steps for managing a diabetic emergency
    let steps = [
        DiabeticStep(
            number: 1,
            title: "Identify the Emergency",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Look for medical warning bracelet or necklace",
                "Check for glucose gel, tablets, or monitoring device",
                "Look for insulin pen, pump, or testing kit"
            ],
            warningNote: "Both high and low blood sugar can be life-threatening. Quick identification is crucial.",
            imageName: "diabetic-1"
        ),
        DiabeticStep(
            number: 2,
            title: "Recognize Symptoms",
            icon: "list.bullet.clipboard.fill",
            instructions: [
                "For High Blood Sugar (Hyperglycaemia):",
                "• Warm, dry skin",
                "• Rapid pulse and breathing",
                "• Fruity, sweet breath",
                "• Excessive thirst",
                "• Drowsiness",
                "For Low Blood Sugar (Hypoglycaemia):",
                "• Weakness, faintness or hunger",
                "• Confusion and irrational behavior",
                "• Sweating with cold, clammy skin",
                "• Rapid pulse and palpitations",
                "• Trembling or shaking"
            ],
            warningNote: nil,
            imageName: "diabetic-2"
        ),
        DiabeticStep(
            number: 3,
            title: "Take Action",
            icon: "hand.raised.fill",
            instructions: [
                "For High Blood Sugar:",
                "Call 999 or 112 immediately",
                "Keep checking breathing and pulse",
                "If unresponsive, start CPR.",
                "For Low Blood Sugar:",
                "Help them sit down",
                "Give sugary food/drink if conscious:",
                "   • 150ml fruit juice or non-diet fizzy drink",
                "   • 3 teaspoons sugar or sugar lumps",
                "   • 3 sweets like jelly babies",
                "If they improve, give more sugary food",
                "If no improvement, call 999 or 112"
            ],
            warningNote: "Never give food or drink to someone who is not fully alert",
            imageName: "diabetic-3"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining diabetic emergencies
                DiabeticIntroCard()
                
                // Display each diabetic step
                ForEach(steps) { step in
                    DiabeticStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Diabetic Emergencies")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.green)
                        Text("Back")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// Introduction card explaining diabetic emergencies
struct DiabeticIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Understanding Diabetic Emergencies")
                .font(.title3)
                .bold()
            
            Text("Diabetes is a condition where the body cannot produce enough insulin to regulate blood sugar levels. Both high (hyperglycaemia) and low (hypoglycaemia) blood sugar can be life-threatening and require immediate attention.")
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card component for each diabetic step with instructions and completion tracking
struct DiabeticStepCard: View {
    let step: DiabeticStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.body)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Step title and icon
                HStack {
                    Text(step.title)
                        .font(.title3)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            // Instructions section with special handling for emergency calls
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if instruction.hasSuffix(":") && instruction != "Give sugary food/drink if conscious:" {
                            // Section headers
                            Text(instruction)
                                .font(.body)
                                .bold()
                                .padding(.bottom, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if instruction.hasPrefix("•") || 
                                  instruction == "150ml fruit juice or non-diet fizzy drink" ||
                                  instruction == "3 teaspoons sugar or sugar lumps" ||
                                  instruction == "3 sweets like jelly babies" {
                            // Bullet points and list items
                            Text(instruction)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.leading, instruction.hasPrefix("   •") ? 48 : 28)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if instruction == "If unresponsive, start CPR." {
                            // Custom checkbox with CPR link
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                    .font(.system(size: 20))
                                
                                (Text("If unresponsive, ")
                                    .foregroundColor(.primary) +
                                Text("start CPR")
                                    .foregroundColor(.green)
                                    .underline() +
                                Text(".")
                                    .foregroundColor(.primary))
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showingCPR = true
                                    }
                                
                                Spacer()
                            }
                            .onTapGesture {
                                if completedSteps.contains(instruction) {
                                    completedSteps.remove(instruction)
                                } else {
                                    completedSteps.insert(instruction)
                                }
                            }
                        } else {
                            // Standard checkbox for other instructions
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
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Add emergency call buttons if needed
                        if instruction.contains("999") || instruction.contains("112") {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Warning note section with emergency call buttons if needed
            if let warning = step.warningNote {
                if step.number == 3 && warning.contains("Never give food") {
                    WarningNote(text: warning)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if step.number != 3 {
                    WarningNote(text: warning)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        // Sheet presentation for CPR guidance
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
}

#Preview {
    NavigationStack {
        DiabeticEmergencyView()
    }
} 