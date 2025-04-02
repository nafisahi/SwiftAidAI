import SwiftUI

struct SymptomCheckerView: View {
    @State private var symptomText = ""
    @State private var showingChat = false
    
    let commonSymptoms = [
        "Chest Pain",
        "Bleeding",
        "Unconscious",
        "Burns",
        "Head Injury",
        "Breathing",
        "Fever",
        "Allergic"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 12) {
                    Text("Symptom Checker")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Tell us what you or someone else is experiencing. We'll guide you step by step.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Symptom Input Field
                VStack(spacing: 8) {
                    HStack {
                        TextField("Describe symptoms...", text: $symptomText)
                            .padding()
                        
                        Button(action: {
                            // Handle mic input
                        }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                // Common Symptoms Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(commonSymptoms, id: \.self) { symptom in
                            SymptomChip(text: symptom) {
                                symptomText = symptom
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Start AI Check Button
                Button(action: {
                    withAnimation {
                        showingChat = true
                    }
                }) {
                    HStack {
                        Image(systemName: "stethoscope")
                        Text("Start AI Check")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
                    .padding(.horizontal)
                }
                .disabled(symptomText.isEmpty)
                .opacity(symptomText.isEmpty ? 0.6 : 1)
            }
        }
        .sheet(isPresented: $showingChat) {
            SymptomChatView(initialSymptom: symptomText)
        }
    }
}

struct SymptomChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        }
        .foregroundColor(.blue)
    }
}

struct SymptomChatView: View {
    let initialSymptom: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // AI Message
                    ChatBubble(
                        text: "I understand you're experiencing: \(initialSymptom). Let me ask you a few questions to help.",
                        isUser: false
                    )
                    
                    // Add more chat bubbles as needed
                }
                .padding()
            }
            .navigationTitle("AI Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(text)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isUser ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(isUser ? .white : .primary)
            
            if !isUser { Spacer() }
        }
    }
}

#Preview {
    SymptomCheckerView()
} 