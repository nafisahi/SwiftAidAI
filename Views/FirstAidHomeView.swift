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
    
    // All first aid topics with their subtopics
    let allFirstAidTopics: [FirstAidTopic] = [
        // Critical Emergencies
        FirstAidTopic(
            category: .critical,
            title: "Critical Emergencies",
            subtitle: "Life-threatening situations",
            icon: "heart.fill",
            color: .red,
            subtopics: [
                "Primary Survey (DR ABC)",
                "Unresponsive and Not Breathing (CPR)",
                "Unresponsive but Breathing",
                "Choking",
                "Severe Bleeding",
                "Shock",
                "Heart Attack",
                "Stroke",
                "Anaphylaxis"
            ],
            subtopicKeywords: [
                "Primary Survey (DR ABC)": ["danger", "response", "airway", "breathing", "circulation", "dr abc", "check breathing", "check pulse"],
                "Unresponsive and Not Breathing (CPR)": ["cpr", "no pulse", "not breathing", "cardiac arrest", "chest compressions", "rescue breaths", "heart stopped"],
                "Unresponsive but Breathing": ["recovery position", "unconscious", "passed out", "fainted", "breathing", "side position"],
                "Choking": ["choking", "can't breathe", "airway blocked", "heimlich maneuver", "back blows", "abdominal thrusts"],
                "Severe Bleeding": ["heavy bleeding", "blood loss", "hemorrhage", "wound", "deep cut", "tourniquet", "pressure"],
                "Shock": ["shock", "pale", "clammy", "rapid pulse", "weak pulse", "dizzy", "cold sweat"],
                "Heart Attack": ["chest pain", "heart attack", "arm pain", "shortness of breath", "nausea", "jaw pain"],
                "Stroke": ["face drooping", "arm weakness", "speech difficulty", "time to call", "fast test", "numbness"],
                "Anaphylaxis": ["allergic reaction", "difficulty breathing", "swelling", "epipen", "rash", "throat closing"]
            ]
        ),
        
        // Bleeding & Wounds
        FirstAidTopic(
            category: .wounds,
            title: "Bleeding & Wounds",
            subtitle: "Cuts, wounds, and severe bleeding",
            icon: "drop.fill",
            color: Color(red: 0.8, green: 0.2, blue: 0.2),
            subtopics: [
                "Severe Bleeding",
                "Minor Cuts and Grazes",
                "Nosebleeds",
                "Blisters"
            ],
            subtopicKeywords: [
                "Severe Bleeding": ["heavy bleeding", "blood loss", "hemorrhage", "deep cut", "wound", "tourniquet", "bandage"],
                "Minor Cuts and Grazes": ["small cut", "graze", "scratch", "abrasion", "antiseptic", "band aid", "plaster"],
                "Nosebleeds": ["nose bleed", "bleeding nose", "epistaxis", "blood from nose", "pinch nose"],
                "Blisters": ["blister", "friction burn", "fluid filled", "bubble on skin", "foot blister", "hand blister"]
            ]
        ),
        
        // Burns & Scalds
        FirstAidTopic(
            category: .burns,
            title: "Burns & Scalds",
            subtitle: "Thermal, chemical, and electrical burns",
            icon: "flame.fill",
            color: .orange,
            subtopics: [
                "Chemical Burns",
                "Severe Burns",
                "Minor Burns",
                "Sunburn"
            ],
            subtopicKeywords: [
                "Chemical Burns": ["chemical burn", "acid burn", "alkali burn", "chemical splash", "eye burn", "skin burn"],
                "Severe Burns": ["third degree", "second degree", "deep burn", "serious burn", "skin charred", "burn treatment"],
                "Minor Burns": ["first degree", "superficial burn", "small burn", "kitchen burn", "hot water burn", "steam burn"],
                "Sunburn": ["sun burn", "sunburned", "sun exposure", "red skin", "blistering", "sun protection"]
            ]
        ),
        
        // Bone & Joint Injuries
        FirstAidTopic(
            category: .bones,
            title: "Bone & Joint Injuries",
            subtitle: "Fractures, sprains, and strains",
            icon: "figure.walk",
            color: .purple,
            subtopics: [
                "Broken Bones",
                "Sprains",
                "Dislocations",
                "Spinal Injuries"
            ],
            subtopicKeywords: [
                "Broken Bones": ["fracture", "broken", "bone break", "compound fracture", "bone pain", "can't move"],
                "Sprains": ["sprained ankle", "twisted joint", "ligament injury", "swollen joint", "joint pain", "strain"],
                "Dislocations": ["dislocated joint", "shoulder out", "knee cap", "joint out of place", "popped out"],
                "Spinal Injuries": ["back injury", "neck injury", "spine hurt", "can't feel legs", "tingling", "paralysis"]
            ]
        ),
        
        // Breathing Issues
        FirstAidTopic(
            category: .breathing,
            title: "Breathing Issues",
            subtitle: "Respiratory emergencies",
            icon: "lungs.fill",
            color: .blue,
            subtopics: [
                "Asthma Attacks",
                "Hyperventilation"
            ],
            subtopicKeywords: [
                "Asthma Attacks": ["asthma", "wheezing", "inhaler", "can't breathe", "tight chest", "difficulty breathing"],
                "Hyperventilation": ["breathing fast", "panic attack", "rapid breathing", "dizzy", "tingling", "anxiety"]
            ]
        ),
        
        // Head & Brain
        FirstAidTopic(
            category: .head,
            title: "Head & Brain",
            subtitle: "Concussion and head injuries",
            icon: "brain.head.profile",
            color: Color(red: 0.3, green: 0.3, blue: 0.8),
            subtopics: [
                "Concussion",
                "Skull Fracture",
                "Brain Injury"
            ],
            subtopicKeywords: [
                "Concussion": ["head injury", "dizzy", "confused", "memory loss", "headache", "nausea", "light sensitive"],
                "Skull Fracture": ["head trauma", "skull injury", "bleeding from ear", "bruising behind ear", "depression in skull"],
                "Brain Injury": ["head trauma", "unconscious", "seizure", "vomiting", "unequal pupils", "severe headache"]
            ]
        ),
        
        // Medical & Poisoning
        FirstAidTopic(
            category: .medical,
            title: "Medical & Poisoning",
            subtitle: "Conditions and toxic exposure",
            icon: "cross.case.fill",
            color: .green,
            subtopics: [
                "Diabetic Emergencies",
                "Food Poisoning",
                "Alcohol Poisoning"
            ],
            subtopicKeywords: [
                "Diabetic Emergencies": ["diabetes", "high sugar", "low sugar", "insulin", "confused", "sweating", "shaky"],
                "Food Poisoning": ["food poison", "vomiting", "diarrhea", "stomach pain", "nausea", "food borne"],
                "Alcohol Poisoning": ["drunk", "alcohol overdose", "unconscious", "vomiting", "slow breathing", "confusion"]
            ]
        ),
        
        // Environmental
        FirstAidTopic(
            category: .environmental,
            title: "Environmental",
            subtitle: "Heat, cold, and natural hazards",
            icon: "thermometer.sun.fill",
            color: .teal,
            subtopics: [
                "Heatstroke",
                "Hypothermia"
            ],
            subtopicKeywords: [
                "Heatstroke": ["heat exhaustion", "overheating", "hot", "dehydrated", "not sweating", "confusion", "headache"],
                "Hypothermia": ["too cold", "freezing", "shivering", "cold exposure", "pale", "slow breathing", "confusion"]
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search all first aid topics", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemBackground))
                
                ScrollView {
                    if searchText.isEmpty {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(searchResults) { result in
                                NavigationLink(destination: destinationView(for: result.topic)) {
                                    EmergencyTopicCard(topic: EmergencyTopic(
                                        id: result.topic.id,
                                        title: result.title,
                                        subtitle: result.subtitle,
                                        icon: result.icon,
                                        color: result.color,
                                        category: result.topic.category
                                    ))
                                }
                            }
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(searchResults) { result in
                                NavigationLink(destination: destinationView(for: result.topic)) {
                                    SubtopicCard(result: result)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("First Aid Guide")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func destinationView(for topic: FirstAidTopic) -> some View {
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
    
    var searchResults: [SearchResult] {
        if searchText.isEmpty {
            return allFirstAidTopics.map { topic in
                SearchResult(
                    topic: topic,
                    matchingSubtopics: topic.subtopics,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    icon: topic.icon,
                    color: topic.color
                )
            }
        }
        
        let searchTerms = searchText.lowercased().split(separator: " ")
        var results: [SearchResult] = []
        
        for topic in allFirstAidTopics {
            var matchingSubtopics: [String] = []
            
            // Check each subtopic and its keywords
            if let subtopicKeywords = topic.subtopicKeywords {
                for (subtopic, keywords) in subtopicKeywords {
                    let keywordMatches = keywords.contains { keyword in
                        searchTerms.contains { term in
                            keyword.lowercased().contains(term)
                        }
                    }
                    
                    let subtopicMatches = searchTerms.contains { term in
                        subtopic.lowercased().contains(term)
                    }
                    
                    if keywordMatches || subtopicMatches {
                        matchingSubtopics.append(subtopic)
                    }
                }
            }
            
            // Check if topic title or subtitle matches
            let topicText = topic.title.lowercased() + " " + topic.subtitle.lowercased()
            let hasMatchingTopicText = searchTerms.contains { term in
                topicText.contains(term)
            }
            
            if !matchingSubtopics.isEmpty || hasMatchingTopicText {
                results.append(SearchResult(
                    topic: topic,
                    matchingSubtopics: matchingSubtopics,
                    title: topic.title,
                    subtitle: !matchingSubtopics.isEmpty ? matchingSubtopics.joined(separator: ", ") : topic.subtitle,
                    icon: topic.icon,
                    color: topic.color
                ))
            }
        }
        
        return results
    }
}

// First Aid Topic with subtopics
struct FirstAidTopic: Identifiable {
    let id = UUID()
    let category: EmergencyCategory
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let subtopics: [String]
    let subtopicKeywords: [String: [String]]?
    
    init(category: EmergencyCategory, title: String, subtitle: String, icon: String, color: Color, subtopics: [String], subtopicKeywords: [String: [String]]? = nil) {
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.subtopics = subtopics
        self.subtopicKeywords = subtopicKeywords
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

struct SubtopicCard: View {
    let result: HomeContentView.SearchResult
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(result.color.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: result.icon)
                    .font(.system(size: 24))
                    .foregroundColor(result.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(result.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(result.color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// Add SearchResult type
extension HomeContentView {
    struct SearchResult: Identifiable {
        let id = UUID()
        let topic: FirstAidTopic
        let matchingSubtopics: [String]
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
    }
}
