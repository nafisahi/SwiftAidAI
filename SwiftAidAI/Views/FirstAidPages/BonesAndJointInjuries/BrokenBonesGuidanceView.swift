import SwiftUI
import Combine

// Data structure for fracture step information with unique ID, number, title, icon, instructions, warning note, and optional image
struct FractureStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for broken bones guidance with instructions
struct BrokenBonesGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    
    // Predefined list of fracture treatment steps
    let steps = [
        FractureStep(
            number: 1,
            title: "Assess Fracture Type",
            icon: "cross.case.fill",
            instructions: [
                "Check if it's an open fracture (bone visible/skin broken).",
                "Check if it's a long bone, back, neck, or pelvis injury.",
                "For open fractures or serious injuries, call 999 or 112 immediately."
            ],
            warningNote: "Open fractures and injuries to long bones, back, neck, or pelvis require immediate emergency care.",
            imageName: "chemical-burn-1"
        ),
        
        FractureStep(
            number: 2,
            title: "Remove Constrictions",
            icon: "hand.raised.fill",
            instructions: [
                "Remove any rings, watches, or jewelry.",
                "Remove anything that wraps around the injured limb.",
                "Do this as soon as possible before swelling occurs."
            ],
            warningNote: nil,
            imageName: "minor-2"
        ),
        
        FractureStep(
            number: 3,
            title: "Wound Care",
            icon: "bandage.fill",
            instructions: [
                "For open fractures, cover with sterile dressing or clean cloth.",
                "Apply pressure around (not over) the wound.",
                "Secure the dressing with a bandage.",
                "For severe bleeding, call 999 or 112."
            ],
            warningNote: "Never apply pressure directly over protruding bone.",
            imageName: "minor-3"
        ),
        
        FractureStep(
            number: 4,
            title: "Immobilize & Support",
            icon: "hand.point.up.fill",
            instructions: [
                "Keep the casualty still.",
                "Support joints above and below the injury.",
                "Place padding around the injury for support.",
                "Check for sensation changes in the affected area."
            ],
            warningNote: "Do not move the casualty unless they're in immediate danger.",
            imageName: "fracture-4"
        ),
        
        FractureStep(
            number: 5,
            title: "Check Sensation",
            icon: "hand.raised.fill",
            instructions: [
                "Ask if the area feels:",
                "• Normal",
                "• Has pins and needles sensation",
                "• Feels unusually hot or cold",
                "• Is numb or has lost feeling",
                "Call 999 or 112 if there are concerning changes in sensation."
            ],
            warningNote: "Changes in sensation could indicate nerve damage.",
            imageName: "broken-bones-5"
        ),
        
        FractureStep(
            number: 6,
            title: "Secure & Monitor",
            icon: "checkmark.shield.fill",
            instructions: [
                "Secure upper limb fractures with a sling.",
                "Secure lower limb fractures with broad fold bandages.",
                "Monitor for signs of shock.",
                "If shock develops, call 999 or 112."
            ],
            warningNote: "Do not raise legs if broken or if there's injury to pelvis/hip.",
            imageName: "fracture-4"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction card explaining fractures
                FractureIntroCard()
                
                // Display each fracture treatment step
                ForEach(steps) { step in
                    FractureStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Footer with attribution information
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Broken Bones (Fractures)")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.purple)
                        Text("Back")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

// Introduction card explaining what a fracture is
struct FractureIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is a fracture?")
                .font(.title2)
                .bold()
            
            Text("A break or crack in a bone is called a fracture. Open fractures present as an open wound near the broken bone, while closed fractures have intact skin. Broken bones may be unstable, causing internal bleeding and shock.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// Card component for each fracture step with instructions and completion tracking
struct FractureStepCard: View {
    let step: FractureStep
    @Binding var completedSteps: Set<String>
    
    // Helper function to check if text contains emergency numbers
    private func hasEmergencyNumbers(_ text: String) -> Bool {
        text.contains("999") || text.contains("112")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number, title, and icon
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
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
                        .foregroundColor(.purple)
                }
            }
            
            // Add the image if present
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions with checkboxes or bullet points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if step.number == 5 {
                            if instruction == "Ask if the area feels:" {
                                // Show checkbox only for the main instruction
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
                            } else if instruction == "Call 999 or 112 if there are concerning changes in sensation." {
                                // Show checkbox for the emergency call instruction
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
                                // Show bullet points for the other sub-points
                                HStack(alignment: .top, spacing: 8) {
                                    Text(instruction)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.leading, 28)
                            }
                        } else {
                            // Regular checkbox for other steps
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
                        
                        // Show emergency call buttons if instruction contains emergency numbers
                        if hasEmergencyNumbers(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                WarningNote(text: warning)
                
                // Show emergency buttons after warning if it contains emergency numbers
                if hasEmergencyNumbers(warning) {
                    SharedEmergencyCallButtons()
                        .padding(.top, 4)
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
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BrokenBonesGuidanceView()
    }
} 