import SwiftUI

struct BlisterStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct BlisterGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    
    let steps = [
        BlisterStep(
            number: 1,
            title: "Clean the Area",
            icon: "drop.fill",
            instructions: [
                "Wash the skin around the blister with clean water.",
                "Gently pat the skin dry with a sterile gauze pad or clean, non-fluffy cloth.",
                "If you cannot wash the area, try to keep it as clean as possible."
            ],
            warningNote: nil,
            imageName: "blister-1"
        ),
        BlisterStep(
            number: 2,
            title: "Protect the Blister",
            icon: "bandage.fill",
            instructions: [
                "Cover the blister with a plaster.",
                "Make sure the pad on the plaster is larger than the blister area.",
                "Ideally use a special blister plaster, as these have a cushioned pad."
            ],
            warningNote: "Don't burst the blister as this can increase the risk of infection",
            imageName: "blister-2"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BlisterIntroCard()
                
                ForEach(steps) { step in
                    BlisterStepCard(step: step, completedSteps: $completedSteps)
                }
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Blisters")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
            }
        }
    }
}

struct BlisterIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are Blisters?")
                .font(.title2)
                .bold()
            
            Text("Blisters are fluid-filled bumps that form on the skin due to friction or heat. When the skin is damaged, fluid leaks and collects under the top layer, creating a blister.")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct BlisterStepCard: View {
    let step: BlisterStep
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.2, blue: 0.2))
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
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
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
            
            // Warning note
            if let warning = step.warningNote {
                WarningNote(text: warning)
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
                .stroke(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BlisterGuidanceView()
    }
} 
