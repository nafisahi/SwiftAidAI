import SwiftUI
import Combine

struct AlcoholPoisoningStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct AlcoholPoisoningView: View {
    @State private var completedSteps: Set<String> = []
    @State private var showingCPR = false
    
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
            warningNote: "If they become unresponsive, check breathing and prepare for CPR.",
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AlcoholPoisoningIntroCard()
                
                ForEach(steps) { step in
                    AlcoholPoisoningStepCard(step: step, completedSteps: $completedSteps, showingCPR: $showingCPR)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Alcohol Poisoning")
        .navigationBarTitleDisplayMode(.large)
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

struct AlcoholPoisoningIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is Alcohol Poisoning?")
                .font(.title2)
                .bold()
            
            Text("Alcohol poisoning occurs when someone drinks more alcohol than their body can process. It depresses the nervous system, particularly the brain, weakening mental and physical functions, and can lead to unresponsiveness.")
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

struct AlcoholPoisoningStepCard: View {
    let step: AlcoholPoisoningStep
    @Binding var completedSteps: Set<String>
    @Binding var showingCPR: Bool
    @State private var showingRecoveryPosition = false
    
    private func shouldHaveCheckbox(_ text: String) -> Bool {
        let checkboxItems = [
            "Look for these signs:",
            "Later signs may include:",
            "Call 999 or 112 if:",
            "Monitor their response level until:",
            "Reassure them and keep them warm",
            "Check for injuries, especially head injuries",
            "Look for signs of other medical conditions",
            "If conscious and not vomiting, offer sips of water",
            "Place them in the recovery position to prevent choking"
        ]
        return checkboxItems.contains(text)
    }
    
    private func createCheckboxWithRecoveryLink(_ instruction: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: completedSteps.contains(instruction) ? "checkmark.square.fill" : "square")
                .foregroundColor(.primary)
                .font(.system(size: 20))
            
            (Text("Place them in the ")
                .foregroundColor(.primary) +
            Text("recovery position")
                .foregroundColor(.purple)
                .underline() +
            Text(" to prevent choking")
                .foregroundColor(.primary))
                .font(.body)
        }
        .padding(.leading, 8)
        .onTapGesture {
            if completedSteps.contains(instruction) {
                completedSteps.remove(instruction)
            } else {
                completedSteps.insert(instruction)
            }
        }
        .overlay(
            Button(action: { showingRecoveryPosition = true }) {
                Color.clear
                    .contentShape(Rectangle())
            }
            .opacity(0)
        )
    }
    
    private func shouldShowEmergencyButtons(_ text: String) -> Bool {
        return text.contains("999") || text.contains("112")
    }
    
    private var warningHasEmergencyNumbers: Bool {
        if let warning = step.warningNote {
            return warning.contains("999") || warning.contains("112")
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        if instruction.contains("recovery position") {
                            createCheckboxWithRecoveryLink(instruction)
                                .font(.body)
                        } else if shouldHaveCheckbox(instruction) {
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
                            Text(instruction)
                                .font(.body)
                                .foregroundColor(instruction.hasSuffix(":") ? .primary : .secondary)
                                .padding(.leading, instruction.hasPrefix("•") ? 24 : 8)
                                .padding(.vertical, 2)
                        }
                        
                        if instruction.contains("CPR") {
                            CPRWarningNote(showingCPR: $showingCPR)
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                        
                        if shouldShowEmergencyButtons(instruction) {
                            SharedEmergencyCallButtons()
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                if warning.contains("CPR") {
                    CPRWarningNote(showingCPR: $showingCPR)
                } else {
                    WarningNote(text: warning)
                }
                
                if warningHasEmergencyNumbers {
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
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingRecoveryPosition) {
            NavigationStack {
                RecoveryPositionView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingRecoveryPosition = false
                    })
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlcoholPoisoningView()
    }
} 