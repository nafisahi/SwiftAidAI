import SwiftUI

// Data structure for head injury step information
struct HeadInjuryStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for head injury guidance with instructions
struct HeadInjuryGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Array of steps for head injury first aid
    let steps = [
        HeadInjuryStep(
            number: 1,
            title: "Initial Assessment",
            icon: "brain.head.profile",
            instructions: [
                "Check for signs and symptoms:",
                "• Loss of responsiveness",
                "• Scalp wounds",
                "• Dizziness or nausea",
                "• Memory loss of events",
                "• Headache",
                "• Confusion"
            ],
            warningNote: "If they become unresponsive, start CPR immediately",
            imageName: "heart-attack-1"
        ),
        HeadInjuryStep(
            number: 2,
            title: "Immediate Care",
            icon: "snowflake",
            instructions: [
                "Sit the casualty down if responsive",
                "Apply something cold to reduce swelling",
                "Use ice pack or frozen vegetables wrapped in cloth",
                "Apply direct pressure to any wounds",
                "Secure wounds with dressing if needed"
            ],
            warningNote: "Never apply ice directly to the skin",
            imageName: "head-ice"
        ),
        HeadInjuryStep(
            number: 3,
            title: "AVPU Assessment",
            icon: "eye.fill",
            instructions: [
                "A - Alert: Check if their eyes are open",
                "V - Voice: Check if they respond to questions",
                "P - Pain: Check response to pressure (supraorbital)",
                "U - Unresponsive: Check if no response to above",
                "Call 999 or 112 if unresponsive or worried"
            ],
            warningNote: "Call emergency services immediately if they fail to respond to any stimuli",
            imageName: "heart-attack-2"
        ),
        HeadInjuryStep(
            number: 4,
            title: "Serious Symptoms",
            icon: "exclamationmark.triangle.fill",
            instructions: [
                "Watch for serious signs:",
                "• Increased drowsiness",
                "• Persistent headache",
                "• Loss of balance or memory",
                "• Difficulty speaking/walking",
                "• Vomiting episodes",
                "• Double vision",
                "• Seizures",
                "• Blood from ear/nose"
            ],
            warningNote: "Call 999 or 112 immediately if any serious symptoms develop",
            imageName: "heart-attack-2"
        ),
        HeadInjuryStep(
            number: 5,
            title: "Seek Medical Help",
            icon: "cross.fill",
            instructions: [
                "Advise seeking medical help if:",
                "• Age over 65",
                "• Previous brain surgery",
                "• Taking anti-clotting medication",
                "• Drug/alcohol consumption",
                "• No responsible caretaker available",
                "• Symptoms worsen"
            ],
            warningNote: "Do not let them return to sports until cleared by a healthcare professional",
            imageName: "heart-attack-2"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction card explaining head injuries
                HeadInjuryIntroCard()
                
                // Display each head injury step card
                ForEach(steps) { step in
                    HeadInjuryStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution info
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Head Injury")
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
    }
}

// Introduction card explaining head injuries
struct HeadInjuryIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About Head Injuries")
                .font(.title2)
                .bold()
            
            Text("Head injuries can range from mild to severe. Quick assessment and appropriate response are crucial. This guide will help you recognize and respond to different types of head injuries.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
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

// Card component for each head injury step with instructions and completion tracking
struct HeadInjuryStepCard: View {
    let step: HeadInjuryStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
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
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
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
                        
                        // Add emergency call buttons if instruction contains emergency numbers
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
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
                            
                            (Text("If they become unresponsive, prepare to ")
                                .foregroundColor(.orange) +
                            Text("start CPR")
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                                .underline())
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                        .padding(.top, 4)
                        .onTapGesture {
                            showingCPR = true
                        }
                    } else {
                        WarningNote(text: warning)
                            .padding(.top, 4)
                        if hasEmergencyNumbers(warning) {
                            SharedEmergencyCallButtons()
                                .padding(.top, 4)
                        }
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
                .stroke(Color(red: 0.3, green: 0.3, blue: 0.8).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingCPR) {
            CPRGuidanceView()
        }
    }
}

#Preview {
    NavigationStack {
        HeadInjuryGuidanceView()
    }
} 