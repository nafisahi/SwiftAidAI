import SwiftUI
import FirebaseFirestore

struct SymptomChatView: View {
    let initialSymptom: String
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var isTyping = false
    @StateObject private var geminiService = GeminiService(apiKey: "AIzaSyBvW-ZZv6bgNf2qp9e1aQQ50Zau38FpG-U")
    @State private var currentTask: Task<Void, Never>?
    @State private var currentMessage = ""
    @StateObject private var chatService = ChatService()
    @State private var currentConversationId: String?
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            // Initial user message
                            MessageView(
                                message: ChatMessage(text: initialSymptom, isUser: true),
                                scrollProxy: proxy,
                                isTyping: $isTyping,
                                onStopTyping: cancelCurrentGeneration
                            )
                            .padding(.top, 16)
                            
                            // AI responses
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
                    Button("Close") {
                        cancelCurrentGeneration()
                        dismiss()
                    }
                }
            }
            .onAppear {
                startConversation()
            }
        }
    }
    
    private func cancelCurrentGeneration() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
        isTyping = false
        
        // If we have a partial message, add it to the messages
        if !currentMessage.isEmpty {
            messages.append(ChatMessage(text: currentMessage, isUser: false))
            currentMessage = ""
        }
    }
    
    private func startConversation() {
        guard let userId = authViewModel.userSession?.uid else { return }
        
        Task {
            do {
                let conversation = try await chatService.createConversation(
                    userId: userId,
                    initialMessage: initialSymptom
                )
                currentConversationId = conversation.id
                await startAIResponse()
            } catch {
                print("Failed to create conversation: \(error)")
            }
        }
    }
    
    private func startAIResponse() async {
        cancelCurrentGeneration() // Cancel any existing task first
        
        currentTask = Task {
            isLoading = true
            currentMessage = ""
            do {
                guard !Task.isCancelled else { return }
                
                // Get the response in chunks
                let analysis = try await geminiService.analyzeSymptoms(initialSymptom)
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    if Task.isCancelled { return }
                    let aiMessage = ChatMessage(text: analysis, isUser: false)
                    messages.append(aiMessage)
                    currentMessage = ""
                    isLoading = false
                    isTyping = true
                    
                    // Save AI response to Firestore
                    if let conversationId = currentConversationId {
                        Task {
                            try? await chatService.addMessage(to: conversationId, message: aiMessage)
                        }
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if Task.isCancelled { return }
                    if !currentMessage.isEmpty {
                        messages.append(ChatMessage(text: currentMessage, isUser: false))
                    } else {
                        messages.append(ChatMessage(text: "I apologize, but I'm having trouble analyzing your symptoms. Please try again.", isUser: false))
                    }
                    currentMessage = ""
                    isLoading = false
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty && !isLoading && !isTyping else { return }
        guard let conversationId = currentConversationId else { return }
        
        let userMessage = ChatMessage(text: userInput, isUser: true)
        messages.append(userMessage)
        userInput = ""
        
        // Save user message to Firestore
        Task {
            try? await chatService.addMessage(to: conversationId, message: userMessage)
        }
        
        cancelCurrentGeneration() // Cancel any existing task first
        
        currentTask = Task {
            isLoading = true
            currentMessage = ""
            do {
                guard !Task.isCancelled else { return }
                
                let response = try await geminiService.analyzeSymptoms(userMessage.text, previousMessages: messages)
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    if Task.isCancelled { return }
                    let aiMessage = ChatMessage(text: response, isUser: false)
                    messages.append(aiMessage)
                    currentMessage = ""
                    isLoading = false
                    isTyping = true
                    
                    // Save AI response to Firestore
                    Task {
                        try? await chatService.addMessage(to: conversationId, message: aiMessage)
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if Task.isCancelled { return }
                    if !currentMessage.isEmpty {
                        messages.append(ChatMessage(text: currentMessage, isUser: false))
                    } else {
                        messages.append(ChatMessage(text: "I apologize, but I'm having trouble processing your response. Could you please rephrase that?", isUser: false))
                    }
                    currentMessage = ""
                    isLoading = false
                }
            }
        }
    }
} 