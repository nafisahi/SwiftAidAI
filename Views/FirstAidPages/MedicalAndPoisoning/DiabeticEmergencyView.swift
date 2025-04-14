import SwiftUI
import Combine

struct DiabeticStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct DiabeticEmergencyView: View {
    @State private var completedSteps: Set<String> = []
    
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
            warningNote: "If they become unresponsive, call 999 or 112 immediately",
            imageName: "diabetic-2"
        ),
        DiabeticStep(
            number: 3,
            title: "Take Action",
            icon: "hand.raised.fill",
            instructions: [
                "For High Blood Sugar:",
                "• Call 999 or 112 immediately",
                "• Keep checking breathing and pulse",
                "• If unresponsive, prepare for CPR",
                "For Low Blood Sugar:",
                "• Help them sit down",
                "• Give sugary food/drink if conscious:",
                "   • 150ml fruit juice or non-diet fizzy drink",
                "   • 3 teaspoons sugar or sugar lumps",
                "   • 3 sweets like jelly babies",
                "• If they improve, give more sugary food",
                "• If no improvement, call 999 or 112"
            ],
            warningNote: "Never give food or drink to someone who is not fully alert",
            imageName: "diabetic-3"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DiabeticIntroCard()
                
                ForEach(steps) { step in
                    DiabeticStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Diabetic Emergencies")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DiabeticIntroCard: View {
    var body: some View {
                    VStack(alignment: .leading, spacing: 12) {
            Text("Understanding Diabetic Emergencies")
                            .font(.title2)
                            .bold()
                        
            Text("Diabetes is a condition where the body cannot produce enough insulin to regulate blood sugar levels. Both high (hyperglycaemia) and low (hypoglycaemia) blood sugar can be life-threatening and require immediate attention.")
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

struct DiabeticStepCard: View {
    let step: DiabeticStep
    @Binding var completedSteps: Set<String>
    @State private var showingCPR = false
    
    private func isBulletPoint(_ text: String) -> Bool {
        text.hasPrefix("•") || text.hasSuffix(":") || text.hasPrefix("-")
    }
    
    // Check if this step has emergency call instructions
    private var hasEmergencyCallInstructions: Bool {
        for instruction in step.instructions {
            if instruction.contains("999") || instruction.contains("112") {
                return true
            }
        }
        return false
    }
    
    // Check if warning note contains emergency numbers
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
                        .fill(Color.green)
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
                        .foregroundColor(.green)
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
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(instruction)
                            .foregroundColor(instruction.hasSuffix(":") ? .primary : .secondary)
                            .padding(.leading, instruction.hasPrefix("-") ? 48 : 8)
                            .padding(.vertical, 2)
                        
                        if instruction.contains("CPR") {
                            CPRWarningNote(showingCPR: $showingCPR)
                                .padding(.leading, 28)
                                .padding(.top, 4)
                        }
                        
                        if instruction.contains("999") || instruction.contains("112") {
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
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
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
        DiabeticEmergencyView()
    }
} 