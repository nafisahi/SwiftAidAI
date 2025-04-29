import SwiftUI

// Data structure for cut and graze step information with unique ID, number, title, icon, instructions, and optional warning/image
struct CutGrazeStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let instructions: [String]
    let warningNote: String?
    let imageName: String?
}

// Main view for cuts and grazes guidance with instructions and completion tracking
struct CutsAndGrazesGuidanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<String> = []
    @State private var showingSevereBleedingSheet = false
    
    // Predefined list of cut and graze treatment steps with detailed instructions and visual aids
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
    
    // Emergency criteria for when to seek medical help
    let emergencyCriteria = [
        "A wound won't stop bleeding.",
        "A foreign object is embedded in the wound.",
        "A wound is from a human or animal bite.",
        "You think the wound might be infected.",
        "You are unsure whether the casualty has been immunised against tetanus."
    ]
    
    // Main view body showing cut and graze treatment steps
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Introduction explaining cuts and grazes
                CutsAndGrazesIntroCard()
                
                // Display each treatment step with completion tracking
                ForEach(steps) { step in
                    CutGrazeStepCard(step: step, completedSteps: $completedSteps)
                }
                
                // Emergency Info Card showing when to seek medical help
                EmergencyInfoCard(
                    criteria: emergencyCriteria,
                    showingSevereBleedingSheet: $showingSevereBleedingSheet
                )
                
                // Footer with attribution info
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
        // Sheet presentation for severe bleeding guidance if needed
        .sheet(isPresented: $showingSevereBleedingSheet) {
            SevereBleedingGuidanceView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

// Introduction card explaining what cuts and grazes are
struct CutsAndGrazesIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Definition of cuts and grazes
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

// Card component for each cut and graze step with instructions and completion tracking
struct CutGrazeStepCard: View {
    let step: CutGrazeStep
    @Binding var completedSteps: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with step number and title
            HStack(spacing: 16) {
                // Circular step number indicator with red background
                ZStack {
                    Circle()
                        .fill(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .frame(width: 32, height: 32)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Step title and icon
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .bold()
                    
                    Image(systemName: step.icon)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
            }
            
            // Step image if available
            if let imageName = step.imageName, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Instructions section containing checkboxes for each step
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
        // Card styling with background, shadow and border
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

// Card showing emergency criteria and when to seek medical help
struct EmergencyInfoCard: View {
    let criteria: [String]
    @Binding var showingSevereBleedingSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with warning icon and title
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                
                Text("Seek Medical Help")
                    .font(.title3)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Divider with custom color
            Divider()
                .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.3))
            
            // Criteria list with special handling for bleeding link
            VStack(alignment: .leading, spacing: 10) {
                Text("Contact emergency services if:")
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 2)
                
                ForEach(criteria, id: \.self) { criterion in
                    if criterion.contains("won't stop bleeding") {
                        // Interactive text for severe bleeding guidance
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
                        // Standard criteria item
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
            
            // Divider with custom color
            Divider()
                .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.3))
                .padding(.vertical, 8)
            
            // Emergency call buttons
            SharedEmergencyCallButtons()
        }
        // Card styling with background, shadow and border
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