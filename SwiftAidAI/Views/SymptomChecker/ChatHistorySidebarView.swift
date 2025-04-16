import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatHistorySidebarView: View {
    @Binding var selectedConversationId: String
    @Environment(\.dismiss) var dismiss
    @State private var conversationTitles: [(id: String, title: String, date: Date)] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?
    @State private var showingDeleteConfirmation = false
    @State private var conversationToDelete: String? = nil
    @State private var showingClearAllConfirmation = false
    let chatHistory = ChatHistoryService()
    var onConversationSelected: ((String, String) -> Void)? // Callback for selection
    
    // Sort conversations by date in descending order
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
                            // Display message when no conversations are available
                            ContentUnavailableView(
                                "No Chat History",
                                systemImage: "clock.arrow.circlepath",
                                description: Text("Your previous conversations will appear here")
                            )
                        } else {
                            // List of conversations
                            ForEach(sortedConversations, id: \.id) { convo in
                                Button(action: {
                                    loadAndSelectConversation(id: convo.id) // Load selected conversation
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(convo.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                        Text(formatDate(convo.date)) // Format and display date
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        conversationToDelete = convo.id
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                deleteConversations(at: indexSet) // Handle conversation deletion
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Dismiss the sidebar
                    }
                }
                
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
            .alert("Clear All Conversations", isPresented: $showingClearAllConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    clearAllConversations()
                }
            } message: {
                Text("Are you sure you want to delete all conversations? This action cannot be undone.")
            }
            .overlay {
                if let error = errorMessage {
                    // Display error message if any
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            setupListener() // Set up Firestore listener on appear
        }
        .onDisappear {
            listener?.remove() // Remove listener on disappear
        }
    }
    
    // Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Delete selected conversations
    private func deleteConversations(at indexSet: IndexSet) {
        for index in indexSet {
            let convo = sortedConversations[index]
            chatHistory.deleteConversation(conversationId: convo.id) { success in
                if success {
                    DispatchQueue.main.async {
                        conversationTitles.removeAll { $0.id == convo.id } // Remove deleted conversation from list
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
        
        print("🔍 Setting up listener for user: \(userId)")
        
        // Remove any existing listener
        listener?.remove()
        
        // Setup real-time listener
        listener = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("conversations")
            .order(by: "updated", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error in snapshot listener: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        errorMessage = "Error loading conversations: \(error.localizedDescription)"
                        isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found in snapshot")
                    DispatchQueue.main.async {
                        conversationTitles.removeAll() // Clear titles if no documents
                        isLoading = false
                    }
                    return
                }
                
                print("📝 Found \(documents.count) conversations")
                
                DispatchQueue.main.async {
                    conversationTitles = documents.compactMap { doc -> (id: String, title: String, date: Date)? in
                        let data = doc.data()
                        print("📄 Processing document ID: \(doc.documentID)")
                        print("   Data: \(data)")
                        
                        guard let title = data["title"] as? String,
                              let updated = data["updated"] as? Timestamp else {
                            print("❌ Missing required fields for document: \(doc.documentID)")
                            return nil
                        }
                        
                        return (id: doc.documentID, title: title, date: updated.dateValue())
                    }
                    print("✅ Successfully loaded \(conversationTitles.count) conversations")
                    isLoading = false
                }
            }
    }
    
    // Load messages for the selected conversation
    private func loadAndSelectConversation(id: String) {
        chatHistory.loadMessages(conversationId: id) { messages in
            if !messages.isEmpty {
                selectedConversationId = id
                dismiss() // Dismiss sidebar after selection
            }
        }
    }
    
    private func deleteConversation(id: String) {
        chatHistory.deleteConversation(conversationId: id) { success in
            if success {
                DispatchQueue.main.async {
                    conversationTitles.removeAll { $0.id == id }
                }
            }
        }
    }
    
    private func clearAllConversations() {
        for conversation in sortedConversations {
            chatHistory.deleteConversation(conversationId: conversation.id) { _ in }
        }
        // The listener will automatically update the UI when the deletions are complete
    }
} 