import SwiftUI

struct StepCard<S: Step>: View {
    let step: S
    let isCompleted: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Step number and title
                HStack(spacing: 12) {
                    Image(systemName: step.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Step \(step.number)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(step.title)
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                // Completion checkbox
                Button(action: {
                    onToggle(!isCompleted)
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                        .font(.system(size: 24))
                }
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.instructions, id: \.self) { instruction in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(instruction)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Warning note if present
            if let warning = step.warningNote {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(warning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }
}

// Protocol definition
protocol Step: Identifiable {
    var id: UUID { get }
    var number: Int { get }
    var title: String { get }
    var icon: String { get }
    var instructions: [String] { get }
    var warningNote: String? { get }
    var imageName: String? { get }
}

// Extensions to conform types to Step protocol
extension ChemicalBurnStep: Step {}
extension SevereBurnStep: Step {}
extension MinorBurnStep: Step {}
extension SunburnStep: Step {} 