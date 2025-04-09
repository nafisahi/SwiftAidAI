import SwiftUI
import Network

struct FirstAidHomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Aid Tab
            NavigationStack {
                HomeContentView()
            }
            .tabItem {
                Label("First Aid", systemImage: "cross.case.fill")
            }
            .tag(0)
            
            // Symptoms Tab
            SymptomCheckerTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Symptoms", systemImage: "stethoscope")
                }
                .tag(1)
            
            // Alert Tab
            AlertView()
                .tabItem {
                    Label("Alert", systemImage: "bell.fill")
                }
                .tag(2)
        }
    }
}

struct HomeContentView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @StateObject private var networkMonitor = NetworkMonitor()
    
    // Grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let emergencyTopics: [EmergencyTopic] = [
        // Critical Emergencies (Red)
        EmergencyTopic(
            id: 1,
            title: "Critical Emergencies",
            subtitle: "Life-threatening situations",
            icon: "heart.fill",
            color: .red,
            category: .critical
        ),
        
        // Bleeding & Wounds (Dark Red)
        EmergencyTopic(
            id: 2,
            title: "Bleeding & Wounds",
            subtitle: "Cuts, wounds, and severe bleeding",
            icon: "drop.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            category: .wounds
        ),
        
        // Burns & Scalds (Orange)
        EmergencyTopic(
            id: 3,
            title: "Burns & Scalds",
            subtitle: "Thermal, chemical, and electrical burns",
            icon: "flame.fill",
            color: .orange,
            category: .burns
        ),
        
        // Bone & Joint Injuries (Purple)
        EmergencyTopic(
            id: 4,
            title: "Bone & Joint Injuries",
            subtitle: "Fractures, sprains, and strains",
            icon: "figure.walk",
            color: .purple,
            category: .bones
        ),
        
        // Breathing Issues (Blue)
        EmergencyTopic(
            id: 5,
            title: "Breathing Issues",
            subtitle: "Respiratory emergencies",
            icon: "lungs.fill",
            color: .blue,
            category: .breathing
        ),
        
        // Head & Brain (Indigo)
        EmergencyTopic(
            id: 6,
            title: "Head & Brain",
            subtitle: "Concussion and head injuries",
            icon: "brain.head.profile",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            category: .head
        ),
        
        // Medical & Poisoning (Green)
        EmergencyTopic(
            id: 7,
            title: "Medical & Poisoning",
            subtitle: "Conditions and toxic exposure",
            icon: "cross.case.fill",
            color: .green,
            category: .medical
        ),
        
        // Environmental (Teal)
        EmergencyTopic(
            id: 8,
            title: "Environmental",
            subtitle: "Heat, cold, and natural hazards",
            icon: "thermometer.sun.fill",
            color: .teal,
            category: .environmental
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation area with blur effect
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        // Profile icon
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.primary)
                        }
                        
                        // Title and Search Bar
                        HStack(spacing: 12) {
                            // Left spacer to help with centering
                            if !isSearching {
                                Spacer()
                            }
                            
                            Text("First Aid")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .opacity(isSearching ? 0 : 1)
                                .animation(.easeInOut(duration: 0.2), value: isSearching)
                            
                            // Right spacer to help with centering
                            if !isSearching {
                                Spacer()
                            }
                            
                            // Animated Search Bar
                            HStack {
                                if isSearching {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                        
                                        TextField("Search first aid topics", text: $searchText)
                                            .textFieldStyle(PlainTextFieldStyle())
                                        
                                        if !searchText.isEmpty {
                                            Button(action: { searchText = "" }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Button(action: {
                                            searchText = ""
                                            withAnimation {
                                                isSearching = false
                                            }
                                        }) {
                                            Text("Cancel")
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                } else {
                                    Button(action: {
                                        withAnimation {
                                            isSearching = true
                                        }
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 22))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .frame(width: isSearching ? nil : 44)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .background(
                    Color(.systemBackground)
                        .opacity(0.8)
                        .background(.ultraThinMaterial)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                )
                
                // Offline banner if needed
                if !networkMonitor.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                        Text("Offline mode active")
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredTopics) { topic in
                            NavigationLink(destination: destinationView(for: topic)) {
                                EmergencyTopicCard(topic: topic)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func destinationView(for topic: EmergencyTopic) -> some View {
        Group {
            switch topic.category {
            case .critical:
                CriticalEmergenciesView()
            case .wounds:
                BleedingAndWoundsView()
            case .burns:
                BurnsAndScaldsView()
            case .bones:
                BoneAndJointInjuriesView()
            case .breathing:
                BreathingIssuesView()
            case .head:
                HeadAndNeurologicalView()
            case .medical:
                MedicalAndPoisoningView()
            case .environmental:
                EnvironmentalEmergenciesView()
            }
        }
    }
    
    var filteredTopics: [EmergencyTopic] {
        if searchText.isEmpty {
            return emergencyTopics
        }
        return emergencyTopics.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

// Emergency Card Component
struct EmergencyTopicCard: View {
    let topic: EmergencyTopic
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(topic.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: topic.icon)
                    .font(.system(size: 28))
                    .foregroundColor(topic.color)
            }
            
            // Title and subtitle
            VStack(spacing: 4) {
                Text(topic.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(topic.subtitle)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: topic.color.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(topic.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ForEach(0..<3) { index in // Changed from 4 to 3 tabs
                Spacer()
                Button(action: { selectedTab = index }) {
                    VStack {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 22))
                        Text(tabTitle(for: index))
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                }
                .frame(height: 50)
                Spacer()
            }
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 5, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "cross.case.fill"
        case 1: return "stethoscope"
        case 2: return "bell.fill"
        default: return ""
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "First Aid"
        case 1: return "Symptoms"
        case 2: return "Alert"
        default: return ""
        }
    }
}

// Data Model
struct EmergencyTopic: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let category: EmergencyCategory
}

// Add categories enum
enum EmergencyCategory {
    case critical
    case wounds
    case burns
    case bones
    case breathing
    case head
    case medical
    case environmental
}

// Placeholder for Emergency Detail View
struct EmergencyDetailView: View {
    let topic: EmergencyTopic
    
    var body: some View {
        Text("Detail view for \(topic.title)")
            .navigationTitle(topic.title)
    }
}

// Add NetworkMonitor class
class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = true
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

#Preview {
    FirstAidHomeView()
}

struct SymptomCheckerTabView: View {
    @State private var showingSymptomChecker = false
    @Binding var selectedTab: Int
    
    var body: some View {
        Color.clear // Invisible view as placeholder
            .onChange(of: selectedTab) { newValue in
                if newValue == 1 { // 1 is the index of the Symptoms tab
                    showingSymptomChecker = true
                }
            }
            .sheet(isPresented: $showingSymptomChecker) {
                SymptomCheckerView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .onDisappear {
                        // If we're still on the Symptoms tab when the sheet is dismissed,
                        // return to the previous tab. Otherwise, stay on current tab.
                        if selectedTab == 1 {
                            selectedTab = selectedTab == 1 ? 0 : selectedTab
                        }
                    }
            }
    }
}
