import SwiftUI
import FirebaseFirestore 
import FirebaseAuth 

// Main view for symptom checking functionality
struct SymptomCheckerView: View {
    // State variables for managing user input and UI state
    @State private var symptomText = ""
    @State private var showingChat = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @StateObject private var geminiService = GeminiService()
    @StateObject private var chatHistory = ChatHistoryService()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var conversationId: String = UUID().uuidString
    @State private var messages: [ChatMessage] = []
    @State private var showingHistory = false
    @Environment(\.dismiss) var dismiss
    
    init() {
        _geminiService = StateObject(wrappedValue: GeminiService())
    }
    
    // Predefined list of common symptoms for quick selection
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
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section with title and description
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
                    
                    // Symptom input field with clear button
                    VStack(spacing: 8) {
                        HStack {
                            TextField("Describe symptoms...", text: $symptomText)
                                .padding()
                            
                            if !symptomText.isEmpty {
                                Button(action: {
                                    symptomText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 20))
                                        .frame(width: 44, height: 44)
                                }
                                .transition(.opacity)
                                .animation(.easeInOut, value: symptomText.isEmpty)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Horizontal scrollable list of common symptoms
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
                    
                    // Main action button to start symptom analysis
                    Button(action: {
                        Task {
                            await analyzeSymptoms()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "stethoscope")
                                Text("Start AI Check")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.teal)
                        )
                        .padding(.horizontal)
                    }
                    .disabled(symptomText.isEmpty || isLoading)
                    .opacity(symptomText.isEmpty || isLoading ? 0.6 : 1)
                    
                    // Error message display
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                }
            }
            .toolbar {
                // History button in navigation bar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingHistory.toggle() }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.teal)
                    }
                }
                
                // Close button in navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            // Present chat history sidebar
            .sheet(isPresented: $showingHistory) {
                ChatHistorySidebarView(selectedConversationId: $conversationId)
            }
            // Present full-screen chat view
            .fullScreenCover(isPresented: $showingChat) {
                SymptomChatView(initialMessage: ChatMessage(text: symptomText, isUser: true))
            }
            // Load existing messages when view appears
            .onAppear {
                chatHistory.loadMessages(conversationId: conversationId) { loaded in
                    self.messages = loaded
                }
            }
        }
    }
    
    // Analyze symptoms using AI service
    private func analyzeSymptoms() async {
        guard networkMonitor.isConnected else {
            errorMessage = "Please check your internet connection to use the Symptom Checker."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Test AI service connection before proceeding
            _ = try await geminiService.analyzeSymptoms(symptomText)
            showingChat = true
        } catch {
            errorMessage = "Failed to analyze symptoms: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Send message to AI and handle response
    private func sendMessage() {
        let userMessage = ChatMessage(text: symptomText, isUser: true)
        messages.append(userMessage)
        chatHistory.saveMessage(userMessage, conversationId: conversationId)
        chatHistory.saveConversationMetadata(conversationId: conversationId, title: symptomText)

        Task {
            do {
                let reply = try await geminiService.analyzeSymptoms(symptomText)
                DispatchQueue.main.async {
                    let aiMessage = ChatMessage(text: reply, isUser: false)
                    messages.append(aiMessage)
                    chatHistory.saveMessage(aiMessage, conversationId: conversationId)
                    chatHistory.updateConversationTimestamp(conversationId: conversationId)
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to analyze symptoms: \(error.localizedDescription)"
                }
            }
        }
    }
}

// Reusable chip component for common symptoms
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
                        .fill(Color.teal.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                )
        }
        .foregroundColor(.teal)
    }
}

// Custom text editor that expands based on content
struct ExpandingTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @State private var textHeight: CGFloat = 36
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(.systemGray2))
                        .padding(.leading, 4)
                        .padding(.top, 8)
                }
                
                TextEditor(text: $text)
                    .frame(height: min(textHeight, 100))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onChange(of: text) { _ in
                        let size = text.boundingRect(
                            with: CGSize(width: geometry.size.width - 16, height: .greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
                            context: nil
                        )
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            textHeight = max(36, min(size.height + 16, 100))
                        }
                    }
            }
        }
        .frame(height: textHeight)
    }
}

// Custom input toolbar for chat interface
struct MessageInputToolbar: View {
    @Binding var text: String
    @Binding var isTyping: Bool
    let isLoading: Bool
    let onSend: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(.systemGray5))
            
            HStack(alignment: .center, spacing: 12) {
                // Message input field
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 44)
                    
                    TextField("Type a message...", text: $text)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .disabled(isLoading || isTyping)
                }
                
                if isLoading || isTyping {
                    // Stop button for canceling current generation
                    Button(action: onStop) {
                        Circle()
                            .fill(Color.teal.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.teal)
                                    .imageScale(.medium)
                            }
                    }
                }
                
                // Send button with loading state
                Button(action: onSend) {
                    Circle()
                        .fill(text.isEmpty || isLoading || isTyping ? Color(.systemGray4) : Color.teal)
                        .frame(width: 44, height: 44)
                        .overlay {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .imageScale(.medium)
                            }
                        }
                }
                .disabled(text.isEmpty || isLoading || isTyping)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
}

// Chat interface for symptom analysis
struct SymptomChatView: View {
    let initialMessage: ChatMessage
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var isTyping = false
    @StateObject private var geminiService = GeminiService()
    @StateObject private var chatHistory = ChatHistoryService()
    @State private var conversationId: String = UUID().uuidString
    @State private var showingHistory = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageView(
                                    message: message,
                                    scrollProxy: proxy,
                                    isTyping: $isTyping,
                                    onStopTyping: cancelCurrentGeneration
                                )
                            }
                            
                            if isLoading {
                                HStack(spacing: 12) {
                                    AvatarView(systemName: "stethoscope.circle.fill")
                                    ProgressView()
                                        .scaleEffect(1.2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                            
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                MessageInputToolbar(
                    text: $userInput,
                    isTyping: $isTyping,
                    isLoading: isLoading,
                    onSend: sendMessage,
                    onStop: cancelCurrentGeneration
                )
            }
            .navigationTitle("AI Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingHistory.toggle() }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.teal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.teal)
                }
            }
            .sheet(isPresented: $showingHistory) {
                ChatHistorySidebarView(selectedConversationId: $conversationId)
            }
        }
        .onAppear {
            startConversation()
        }
    }
    
    // Initialize conversation with initial message
    private func startConversation() {
        messages = [initialMessage]
        chatHistory.saveMessage(initialMessage, conversationId: conversationId)
        chatHistory.saveConversationMetadata(conversationId: conversationId, title: initialMessage.text)
        
        Task {
            isLoading = true
            do {
                let analysis = try await geminiService.analyzeSymptoms(initialMessage.text)
                let aiMessage = ChatMessage(text: analysis, isUser: false)
                
                await MainActor.run {
                    messages.append(aiMessage)
                    chatHistory.saveMessage(aiMessage, conversationId: conversationId)
                    chatHistory.updateConversationTimestamp(conversationId: conversationId)
                    isLoading = false
                    isTyping = true
                }
            } catch {
                await MainActor.run {
                    let errorMessage = "I apologize, but I'm having trouble analyzing your symptoms. Please try again."
                    let aiMessage = ChatMessage(text: errorMessage, isUser: false)
                    messages.append(aiMessage)
                    chatHistory.saveMessage(aiMessage, conversationId: conversationId)
                    isLoading = false
                }
            }
        }
    }
    
    // Cancel current AI response generation
    private func cancelCurrentGeneration() {
        isLoading = false
        isTyping = false
    }
    
    // Send user message and handle AI response
    private func sendMessage() {
        guard !userInput.isEmpty && !isLoading && !isTyping else { return }
        
        let userMessage = ChatMessage(text: userInput, isUser: true)
        messages.append(userMessage)
        chatHistory.saveMessage(userMessage, conversationId: conversationId)
        chatHistory.updateConversationTimestamp(conversationId: conversationId)
        
        let currentInput = userInput
        userInput = ""
        
        Task {
            isLoading = true
            do {
                let response = try await geminiService.analyzeSymptoms(currentInput, previousMessages: messages)
                let aiMessage = ChatMessage(text: response, isUser: false)
                
                await MainActor.run {
                    messages.append(aiMessage)
                    chatHistory.saveMessage(aiMessage, conversationId: conversationId)
                    chatHistory.updateConversationTimestamp(conversationId: conversationId)
                    isLoading = false
                    isTyping = true
                }
            } catch {
                await MainActor.run {
                    let errorMessage = "I apologize, but I'm having trouble processing your response. Could you please rephrase that?"
                    let aiMessage = ChatMessage(text: errorMessage, isUser: false)
                    messages.append(aiMessage)
                    chatHistory.saveMessage(aiMessage, conversationId: conversationId)
                    isLoading = false
                }
            }
        }
    }
}

// View for displaying individual chat messages
struct MessageView: View {
    let message: ChatMessage
    let scrollProxy: ScrollViewProxy
    @Binding var isTyping: Bool
    let onStopTyping: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if !message.isUser {
                AvatarView(systemName: "stethoscope.circle.fill")
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if !message.isUser {
                    Text("AI Assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
                
                if message.isUser {
                    Text(message.text)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.teal)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                } else {
                    FormattedAIResponse(
                        text: message.text,
                        isTyping: $isTyping,
                        scrollProxy: scrollProxy,
                        onStopTyping: onStopTyping
                    )
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if message.isUser {
                AvatarView(systemName: "person.circle.fill")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

// Avatar view for chat participants
struct AvatarView: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundStyle(.teal)
            .font(.system(size: 28, weight: .regular))
            .symbolRenderingMode(.multicolor)
            .frame(width: 36, height: 36)
    }
}

// Typewriter effect for AI responses
struct TypewriterText: View {
    let text: String
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @Binding var isAnimating: Bool
    let typingSpeed: Double
    let onCharacterTyped: () -> Void
    
    init(text: String, isAnimating: Binding<Bool>, typingSpeed: Double = 0.03, onCharacterTyped: @escaping () -> Void = {}) {
        self.text = text
        self._isAnimating = isAnimating
        self.typingSpeed = typingSpeed
        self.onCharacterTyped = onCharacterTyped
    }
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < text.count && isAnimating {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText.append(text[index])
                currentIndex += 1
                onCharacterTyped()
            } else {
                timer.invalidate()
                if currentIndex < text.count {
                    displayedText = text
                }
            }
        }
    }
}

// Formatted AI response with typewriter effect
struct FormattedAIResponse: View {
    let text: String
    @Binding var isTyping: Bool
    let scrollProxy: ScrollViewProxy
    let onStopTyping: () -> Void
    @State private var displayedText = ""
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayedText)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
        .onAppear {
            startTyping()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startTyping() {
        displayedText = ""
        let formattedText = formatText(text)
        var currentIndex = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if currentIndex < formattedText.count && isTyping {
                let index = formattedText.index(formattedText.startIndex, offsetBy: currentIndex)
                displayedText.append(formattedText[index])
                currentIndex += 1
                
                withAnimation {
                    scrollProxy.scrollTo("bottom", anchor: .bottom)
                }
            } else {
                timer.invalidate()
                if !isTyping {
                    onStopTyping()
                } else if currentIndex < formattedText.count {
                    displayedText = formattedText
                }
                isTyping = false
            }
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // Format text with proper spacing and list formatting
    private func formatText(_ text: String) -> String {
        let sections = text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var formattedText = ""
        
        for (index, section) in sections.enumerated() {
            if section.contains("•") || section.contains("1.") || section.contains("2.") || section.contains("3.") {
                formattedText += section.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .joined(separator: "\n")
            } else {
                formattedText += section
            }
            
            if index < sections.count - 1 {
                formattedText += "\n\n"
            }
        }
        
        return formattedText
    }
}

#Preview {
    SymptomCheckerView()
} 