import SwiftUI

struct BleedingStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct SevereBleedingGuidanceView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    
    let steps = [
        BleedingStep(
            number: 1,
            title: "Wear Protective Gloves",
            icon: "hand.raised.fill",
            instructions: [
                "Wear protective first aid gloves if available",
                "This helps prevent infection passing between you both"
            ],
            warningNote: "With open wounds there's a risk of infection",
            imageName: "step1-bleed"
        ),
        BleedingStep(
            number: 2,
            title: "Stop Bleeding",
            icon: "hand.point.down.fill",
            instructions: [
                "Apply direct firm pressure to the wound",
                "Use sterile dressing or clean non-fluffy cloth",
                "Ask casualty to apply pressure if no dressing available",
                "Remove or cut clothing to uncover wound if needed"
            ],
            warningNote: "If there's an object in the wound, don't pull it out - apply pressure on either side to push edges together",
            imageName: "step2-bleed"
        ),
        BleedingStep(
            number: 3,
            title: "Call for Help",
            icon: "phone.fill",
            instructions: [
                "Ask helper to call 999 or 112 for emergency help",
                "Describe wound location and extent of bleeding",
                "If alone, use phone's speaker while treating casualty"
            ],
            warningNote: nil,
            imageName: "step3-bleed"
        ),
        BleedingStep(
            number: 4,
            title: "Secure Dressing",
            icon: "bandage.fill",
            instructions: [
                "Firmly secure dressing with bandage",
                "Maintain pressure on the wound",
                "Ensure bandage isn't restricting circulation"
            ],
            warningNote: "Bandage should be firm but not too tight",
            imageName: "step4-bleed"
        ),
        BleedingStep(
            number: 5,
            title: "Check Circulation",
            icon: "hand.point.up.fill",
            instructions: [
                "Press nail or skin beyond bandage for five seconds until pale",
                "Release pressure and check color returns within two seconds",
                "If color doesn't return quickly, loosen and reapply bandage"
            ],
            warningNote: "Slow color return indicates bandage is too tight",
            imageName: "step5-bleed"
        ),
        BleedingStep(
            number: 6,
            title: "Replace Soaked Dressing",
            icon: "arrow.triangle.2.circlepath",
            instructions: [
                "If blood comes through, remove dressing",
                "Apply new dressing with firm pressure",
                "Secure with bandage, tying knot over wound"
            ],
            warningNote: "Maintain pressure control during dressing change",
            imageName: "step6-bleed"
        ),
        BleedingStep(
            number: 7,
            title: "Support and Monitor",
            icon: "figure.arms.open",
            instructions: [
                "Support injured part with sling or bandage",
                "Check circulation beyond bandage every 10 minutes"
            ],
            warningNote: "Regular circulation checks are essential",
            imageName: "step7-bleed"
        ),
        BleedingStep(
            number: 8,
            title: "Monitor Response",
            icon: "heart.text.square.fill",
            instructions: [
                "Keep monitoring their level of response",
                "Watch for any changes in condition",
                "Follow emergency service instructions if given"
            ],
            warningNote: "If they become unresponsive, prepare to start CPR. Emergency services may instruct you to improvise a tourniquet using items like a triangular bandage, belt, or tie - follow their instructions carefully.",
            imageName: "step8-bleed"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BleedingIntroductionCard()
                
                ForEach(steps) { step in
                    BleedingStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Severe Bleeding")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BleedingIntroductionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why Immediate Action Matters")
                .font(.title2)
                .bold()
            
            Text("Severe bleeding can quickly cause shock, a life-threatening condition where vital organs don't receive enough oxygen. Your priority is to stop the bleeding.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct BleedingStepCard: View {
    let step: BleedingStep
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
                        .fill(Color.red)
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
                        .foregroundColor(.red)
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
                    if step.number == 8 && warning.contains("CPR") {
                        CPRWarningNote(showingCPR: $showingCPR)
                    } else {
                        WarningNote(text: warning)
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
        SevereBleedingGuidanceView()
    }}

