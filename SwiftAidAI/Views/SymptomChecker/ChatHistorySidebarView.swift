import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// View for displaying and managing chat history
struct ChatHistorySidebarView: View {
    // Binding to track selected conversation
    @Binding var selectedConversationId: String
    // Environment variable to dismiss the view
    @Environment(\.dismiss) var dismiss
    // State variables for managing conversations
    @State private var conversationTitles: [(id: String, title: String, date: Date)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?
    @State private var showingDeleteConfirmation = false
    @State private var conversationToDelete: String? = nil
    @State private var showingClearAllConfirmation = false
    // Service for managing chat history
    let chatHistory = ChatHistoryService()
    // Callback when a conversation is selected
    var onConversationSelected: ((String, String) -> Void)?
    
    // Sort conversations by date, newest first
    var sortedConversations: [(id: String, title: String, date: Date)] {
        conversationTitles.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    // Show loading indicator while fetching conversations
                    ProgressView("Loading conversations...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if sortedConversations.isEmpty {
                            // Show empty state message
                            ContentUnavailableView(
                                "No Chat History",
                                systemImage: "clock.arrow.circlepath",
                                description: Text("Your previous conversations will appear here")
                            )
                        } else {
                            // Display list of conversations
                            ForEach(sortedConversations, id: \.id) { convo in
                                Button(action: {
                                    loadAndSelectConversation(id: convo.id)
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(convo.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                        Text(formatDate(convo.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                // Add swipe to delete functionality
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        conversationToDelete = convo.id
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            // Handle batch deletion
                            .onDelete { indexSet in
                                deleteConversations(at: indexSet)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Done button to dismiss view
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                // Clear all button if conversations exist
                if !sortedConversations.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            showingClearAllConfirmation = true
                        } label: {
                            Text("Clear All")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            // Alert for single conversation deletion
            .alert("Delete Conversation", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let id = conversationToDelete {
                        deleteConversation(id: id)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this conversation? This action cannot be undone.")
            }
            // Alert for clearing all conversations
            .alert("Clear All Conversations", isPresented: $showingClearAllConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    clearAllConversations()
                }
            } message: {
                Text("Are you sure you want to delete all conversations? This action cannot be undone.")
            }
            // Show error message if any
            .overlay {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        // Set up and clean up Firestore listener
        .onAppear {
            setupListener()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    // Format date as relative time (e.g., "2 hours ago")
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Delete multiple conversations
    private func deleteConversations(at indexSet: IndexSet) {
        for index in indexSet {
            let convo = sortedConversations[index]
            chatHistory.deleteConversation(conversationId: convo.id) { success in
                if success {
                    DispatchQueue.main.async {
                        conversationTitles.removeAll { $0.id == convo.id }
                    }
                }
            }
        }
    }
    
    // Set up Firestore listener for real-time updates
    private func setupListener() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Please sign in to view chat history"
            isLoading = false
            return
        }
        
        // Remove existing listener
        listener?.remove()
        
        // Set up new listener
        listener = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("conversations")
            .order(by: "updated", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = "Error loading conversations: \(error.localizedDescription)"
                        isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        conversationTitles.removeAll()
                        isLoading = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    conversationTitles = documents.compactMap { doc -> (id: String, title: String, date: Date)? in
                        let data = doc.data()
                        
                        guard let title = data["title"] as? String,
                              let updated = data["updated"] as? Timestamp else {
                            return nil
                        }
                        
                        return (id: doc.documentID, title: title, date: updated.dateValue())
                    }
                    isLoading = false
                }
            }
    }
    
    // Load and select a conversation
    private func loadAndSelectConversation(id: String) {
        chatHistory.loadMessages(conversationId: id) { messages in
            if !messages.isEmpty {
                selectedConversationId = id
                dismiss()
            }
        }
    }
    
    // Delete a single conversation
    private func deleteConversation(id: String) {
        chatHistory.deleteConversation(conversationId: id) { success in
            if success {
                DispatchQueue.main.async {
                    conversationTitles.removeAll { $0.id == id }
                }
            }
        }
    }
    
    // Delete all conversations
    private func clearAllConversations() {
        for conversation in sortedConversations {
            chatHistory.deleteConversation(conversationId: conversation.id) { _ in }
        }
    }
} 