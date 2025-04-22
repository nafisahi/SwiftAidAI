import SwiftUI

struct CutGrazeStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

struct CutsAndGrazesGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    @State private var showingSevereBleedingSheet = false
    
    let steps = [
        CutGrazeStep(
            number: 1,
            title: "Clean the Wound",
            icon: "drop.fill",
            instructions: [
                "Rinse the wound under running water or use sterile wipes.",
                "Do not rub the wound.",
                "Pat the wound dry using a gauze swab.",
                "For a cut, raise and support the injured part above the level of the heart."
            ],
            warningNote: "Avoid touching the wound",
            imageName: "cut-1"
        ),
        CutGrazeStep(
            number: 2,
            title: "Dress the Wound",
            icon: "bandage.fill",
            instructions: [
                "Clean around the wound with soap and water.",
                "Wipe away from the wound, using a clean swab for each stroke.",
                "Pat dry.",
                "Apply a sterile dressing or a large plaster."
            ],
            warningNote: nil,
            imageName: "cut-2"
        )
    ]
    
    // Emergency criteria previously in step 3
    let emergencyCriteria = [
        "A wound won't stop bleeding.",
        "A foreign object is embedded in the wound.",
        "A wound is from a human or animal bite.",
        "You think the wound might be infected.",
        "You are unsure whether the casualty has been immunised against tetanus."
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CutsAndGrazesIntroCard()
                
                ForEach(steps) { step in
                    CutGrazeStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Emergency Info Card (replacing step 3)
                EmergencyInfoCard(
                    criteria: emergencyCriteria,
                    showingSevereBleedingSheet: $showingSevereBleedingSheet
                )
                
                AttributionFooter()
                    .padding(.bottom, 32)
            }
            .padding(.vertical)
        }
        .navigationTitle("Cuts and Grazes")
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
        .sheet(isPresented: $showingSevereBleedingSheet) {
            NavigationStack {
                SevereBleedingGuidanceView()
                    .navigationBarItems(trailing: Button("Done") {
                        showingSevereBleedingSheet = false
                    })
            }
        }
    }
}

struct CutsAndGrazesIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // End of Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("What is a cut?")
                    .font(.headline)
                
                Text("A cut is when the skin is fully broken.")
                    .foregroundColor(.secondary)
                
                Text("What is a graze?")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("A graze is when only the top layers of skin are scraped off.")
                    .foregroundColor(.secondary)
            }
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

struct CutGrazeStepCard: View {
    let step: CutGrazeStep
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
            
            // Warning note if present
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

// New Emergency Info Card
struct EmergencyInfoCard: View {
    let criteria: [String]
    @Binding var showingSevereBleedingSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                
                Text("Seek Medical Help")
                    .font(.title3)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.3))
            
            // Criteria list
            VStack(alignment: .leading, spacing: 10) {
                Text("Contact emergency services if:")
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 2)
                
                ForEach(criteria, id: \.self) { criterion in
                    if criterion.contains("won't stop bleeding") {
                        // Special handling for bleeding link
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                                .padding(.top, 6)
                            
                            HStack(spacing: 0) {
                                Text("If a wound ")
                                    .foregroundColor(.primary)
                                
                                Text("won't stop bleeding")
                                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                                    .bold()
                                    .underline()
                                    .onTapGesture {
                                        showingSevereBleedingSheet = true
                                    }
                            }
                            .font(.subheadline)
                        }
                    } else {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                                .padding(.top, 6)
                            
                            Text(criterion)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            Divider()
                .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.3))
                .padding(.vertical, 8)
            
            // Using SharedEmergencyCallButtons component directly without title
            SharedEmergencyCallButtons()
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
        CutsAndGrazesGuidanceView()
    }
} 