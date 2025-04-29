import SwiftUI
import Combine

// Data structure for alcohol poisoning step information
struct AlcoholPoisoningStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for alcohol poisoning guidance with instructions
struct AlcoholPoisoningView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of steps for managing alcohol poisoning
    let steps = [
        AlcoholPoisoningStep(
            number: 1,
            title: "Recognize Signs",
            icon: "list.bullet.clipboard.fill",
            instructions: [
                "Look for these signs:",
                "• Strong smell of alcohol (empty bottles/cans)",
                "• Reduced response and coordination",
                "• Moist and reddened face",
                "• Deep, noisy breathing",
                "• Full, bounding pulse",
                "• Confusion and slurred speech",
                "• Sickness and vomiting",
                "Later signs may include:",
                "• Shallow breathing",
                "• Weak, rapid pulse",
                "• Dilated pupils with poor light reaction",
                "• Unresponsiveness"
            ],
            warningNote: "Be aware that alcohol smell could disguise other serious conditions like head injury, stroke, heart attack, or low blood sugar.",
            imageName: nil
        ),
        AlcoholPoisoningStep(
            number: 2,
            title: "Initial Actions",
            icon: "person.fill",
            instructions: [
                "Reassure them and keep them warm",
                "Check for injuries, especially head injuries",
                "Look for signs of other medical conditions",
                "If conscious and not vomiting, offer sips of water",
                "Place them in the recovery position to prevent choking"
            ],
            warningNote: "Do not try to make them sick.",
            imageName: nil
        ),
        AlcoholPoisoningStep(
            number: 3,
            title: "Monitor & Get Help",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Call 999 or 112 if:",
                "• You're unsure about their condition",
                "• You suspect a head injury",
                "• They become unresponsive",
                "Monitor their response level until:",
                "• They recover",
                "• A responsible adult takes over",
                "• Emergency help arrives"
            ],
            warningNote: "If they become unresponsive, start CPR immediately.",
            imageName: nil
        )
    ]
    
    // Main view body showing alcohol poisoning steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining alcohol poisoning
                AlcoholPoisoningIntroCard()
                
                // Display each alcohol poisoning step
                ForEach(steps) { step in
                    AlcoholPoisoningStepCard(step: step, completedSteps: $completedSteps, showingCPR: $showingCPR)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Alcohol Poisoning")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
}

// Introduction card explaining what alcohol poisoning is
struct AlcoholPoisoningIntroCard: View {
    // Main container for introduction content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is Alcohol Poisoning?")
                .font(.title3)
                .bold()
            
            Text("Alcohol poisoning occurs when someone drinks more alcohol than their body can process. It depresses the nervous system, particularly the brain, weakening mental and physical functions, and can lead to unresponsiveness.")
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

// Card component for each alcohol poisoning step with instructions and completion tracking
struct AlcoholPoisoningStepCard: View {
    let step: AlcoholPoisoningStep
    @Binding var completedSteps: Set<String>
    @Binding var showingCPR: Bool
    @State private var showingRecoveryPosition = false
    
    // Main container for step content
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
            
            // Instructions section with special handling for emergency calls and recovery position
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if instruction.hasPrefix("•") {
                            // Bullet point instructions
                            Text(instruction)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.leading, 28)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if instruction.contains("recovery position") {
                            // Custom checkbox with recovery position link
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(completedSteps.contains(instruction) ? .green : .gray)
                                    .font(.system(size: 20))
                                
                                (Text("Place them in the ")
                                    .foregroundColor(.primary) +
                                Text("recovery position")
                                    .foregroundColor(.green)
                                    .underline() +
                                Text(" to prevent choking")
                                    .foregroundColor(.primary))
                                    .font(.subheadline)
                                    .onTapGesture {
                                        showingRecoveryPosition = true
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
                        
                        // Show CPR warning note if instruction contains CPR
                        if instruction.contains("CPR") {
                            CPRWarningNote(showingCPR: $showingCPR)
                                .tint(.green)
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                        
                        // Show emergency call buttons if instruction contains emergency numbers
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
                if warning.contains("CPR") {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        
                        (Text("If they become unresponsive, ")
                            .foregroundColor(.orange) +
                        Text("start CPR")
                            .foregroundColor(.green)
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
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if warning.contains("999") || warning.contains("112") {
                    SharedEmergencyCallButtons()
                        .padding(.top, 8)
                }
            }
        }
        // Card styling with background, shadow and border
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
        // Sheet presentation for recovery position guidance
        .sheet(isPresented: $showingRecoveryPosition) {
            RecoveryPositionView()
                .tint(.green)
        }
    }
}

#Preview {
    NavigationStack {
        AlcoholPoisoningView()
    }
} 