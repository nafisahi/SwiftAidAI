import SwiftUI 
import Network
import UserNotifications

struct FirstAidHomeView: View {
    @State private var selectedTab = 0
    @State private var showingNotificationPermission = false
    
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
            .tint(.teal)
            
            // Symptoms Tab
            SymptomCheckerTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Symptoms", systemImage: "stethoscope")
                }
                .tag(1)
                .tint(.teal)
            
            // Alert Tab
            AlertView()
                .tabItem {
                    Label("Alert", systemImage: "bell.fill")
                }
                .tag(2)
                .tint(.teal)
        }
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // Set the selected item color to teal
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.teal)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.teal)]
            
            // Use this appearance for both normal and scrolling
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Request notification permissions
            requestNotificationPermissions()
        }
        .alert("Enable Notifications", isPresented: $showingNotificationPermission) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("SwiftAidAI would like to send you notifications for emergency alerts and important updates.")
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if !granted {
                            DispatchQueue.main.async {
                                showingNotificationPermission = true
                            }
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    showingNotificationPermission = true
                }
            }
        }
    }
}

struct HomeContentView: View {
    @State private var searchText = ""
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var showingProfile = false
    
    // Grid layout
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
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
                "Primary Survey (DR ABC)": ["danger", "response", "airway", "breathing", "circulation", "dr abc"],
                "Unresponsive and Not Breathing (CPR)": ["cpr", "no pulse", "not breathing", "cardiac arrest", "compressions"],
                "Unresponsive but Breathing": ["recovery position", "faint", "breathing unconscious", "passed out"],
                "Choking": ["choke", "airway blocked", "can't breathe", "heimlich", "foreign object"],
                "Severe Bleeding": ["hemorrhage", "bleeding", "blood loss", "major wound"],
                "Shock": ["shock symptoms", "cold skin", "pale", "fast pulse", "faint"],
                "Heart Attack": ["chest pain", "tight chest", "heart", "cardiac", "pain spreading arm"],
                "Stroke": ["face droop", "slurred speech", "fast stroke test", "numbness", "stroke"],
                "Anaphylaxis": ["severe allergy", "swelling", "epipen", "difficulty breathing", "allergic reaction"]
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
                "Severe Bleeding": ["deep wound", "lots of blood", "gushing blood"],
                "Minor Cuts and Grazes": ["small cut", "abrasion", "scratch", "skin wound", "plaster"],
                "Nosebleeds": ["bleeding nose", "blood from nose", "tilt forward"],
                "Blisters": ["friction", "bubble", "blister", "skin burn", "foot sore"]
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
                "Chemical Burns": ["acid", "alkali", "chemical exposure", "corrosive", "eye burn"],
                "Severe Burns": ["deep burn", "third degree", "skin charred", "burn shock"],
                "Minor Burns": ["first degree", "small burn", "blister burn", "scald"],
                "Sunburn": ["sun exposure", "red skin", "peeling", "uv damage", "heat rash"]
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
                "Broken Bones": ["fracture", "snap", "deformed limb", "can't move", "bone sticking out"],
                "Sprains": ["twisted ankle", "swollen joint", "ligament", "strain", "minor injury"],
                "Dislocations": ["out of socket", "shoulder dislocation", "knee cap out", "joint injury"],
                "Spinal Injuries": ["neck injury", "back trauma", "can't feel legs", "spine"]
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
                "Asthma Attacks": ["inhaler", "wheezing", "short of breath", "blue lips", "can't breathe"],
                "Hyperventilation": ["panic", "rapid breathing", "anxiety attack", "tingling hands"]
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
                "Concussion": ["head hit", "dizzy", "confused", "light sensitive", "mild brain injury"],
                "Skull Fracture": ["cracked skull", "bleeding from ear", "depression in skull", "head trauma"],
                "Brain Injury": ["serious head injury", "loss of consciousness", "seizure", "pupil difference"]
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
                "Diabetic Emergencies": ["low sugar", "high sugar", "glucose", "insulin", "diabetes attack"],
                "Food Poisoning": ["vomiting", "diarrhea", "nausea", "bad food", "bacteria"],
                "Alcohol Poisoning": ["drunk", "passed out", "slurred speech", "vomiting alcohol"]
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
                "Heatstroke": ["hot weather", "no sweating", "heat exhaustion", "collapse in sun"],
                "Hypothermia": ["cold", "shivering", "frostbite", "blue skin", "body temperature low"]
            ]
        )
    ]
    
    struct SearchResult: Identifiable {
        let id = UUID()
        let mainTopic: FirstAidTopic
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let category: EmergencyCategory
        let isSubtopic: Bool
    }
    
    var searchResults: [SearchResult] {
        if searchText.isEmpty {
            return allFirstAidTopics.map { topic in
                SearchResult(
                    mainTopic: topic,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    icon: topic.icon,
                    color: topic.color,
                    category: topic.category,
                    isSubtopic: false
                )
            }
        }
        
        var results: [SearchResult] = []
        let searchTerms = searchText.lowercased().split(separator: " ")
        
        for topic in allFirstAidTopics {
            // Check if main topic matches
            let matchesMainTopic = topic.title.lowercased().contains(searchText.lowercased()) ||
                                 topic.subtitle.lowercased().contains(searchText.lowercased())
            
            if matchesMainTopic {
                results.append(SearchResult(
                    mainTopic: topic,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    icon: topic.icon,
                    color: topic.color,
                    category: topic.category,
                    isSubtopic: false
                ))
            }
            
            // Check subtopics and their keywords
            for (subtopic, keywords) in topic.subtopicKeywords {
                let matchesSubtopic = subtopic.lowercased().contains(searchText.lowercased()) ||
                                    searchTerms.allSatisfy { term in
                                        subtopic.lowercased().contains(term) ||
                                        keywords.contains { keyword in
                                            keyword.lowercased().contains(term)
                                        }
                                    }
                
                if matchesSubtopic {
                    results.append(SearchResult(
                        mainTopic: topic,
                        title: subtopic,
                        subtitle: "Part of \(topic.title)",
                        icon: topic.icon,
                        color: topic.color,
                        category: topic.category,
                        isSubtopic: true
                    ))
                }
            }
        }
        
        return results
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation area with blur effect
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.teal)
                        }
                        
                        Spacer()
                        
                        Text("First Aid")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#3A3D40"))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .sheet(isPresented: $showingProfile) {
                        ProfileView()
                    }
                    
                    // Offline Mode Banner
                    if !networkMonitor.isConnected {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text("Offline Mode")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                    }
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Bar
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
                                .frame(width: 44, height: 44)
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Topics Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(searchResults) { result in
                                NavigationLink(destination: destinationView(for: result)) {
                                    if result.isSubtopic {
                                        SubtopicCard(result: result)
                                    } else {
                                        EmergencyTopicCard(topic: EmergencyTopic(
                                            id: 1,
                                            title: result.title,
                                            subtitle: result.subtitle,
                                            icon: result.icon,
                                            color: result.color,
                                            category: result.category
                                        ))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
    
    private func destinationView(for result: SearchResult) -> some View {
        if result.isSubtopic {
            // Direct navigation to specific guidance views for subtopics
            switch result.title {
            // Critical Emergencies subtopics
            case "Primary Survey (DR ABC)":
                return AnyView(PrimarySurveyDetailView())
            case "Unresponsive and Not Breathing (CPR)":
                return AnyView(CPRGuidanceView())
            case "Unresponsive but Breathing":
                return AnyView(RecoveryPositionView())
            case "Choking":
                return AnyView(ChokingGuidanceView())
            case "Severe Bleeding":
                return AnyView(SevereBleedingGuidanceView())
            case "Shock":
                return AnyView(ShockGuidanceView())
            case "Heart Attack":
                return AnyView(HeartAttackGuidanceView())
            case "Stroke":
                return AnyView(StrokeGuidanceView())
            case "Anaphylaxis":
                return AnyView(AnaphylaxisGuidanceView())
                
            // Bleeding & Wounds subtopics
            case "Minor Cuts and Grazes":
                return AnyView(CutsAndGrazesGuidanceView())
            case "Nosebleeds":
                return AnyView(NosebleedGuidanceView())
            case "Blisters":
                return AnyView(BlisterGuidanceView())
                
            // Burns & Scalds subtopics
            case "Chemical Burns":
                return AnyView(ChemicalBurnsGuidanceView())
            case "Severe Burns":
                return AnyView(SevereBurnsGuidanceView())
            case "Minor Burns":
                return AnyView(MinorBurnsGuidanceView())
            case "Sunburn":
                return AnyView(SunburnGuidanceView())
                
            // Bone & Joint Injuries subtopics
            case "Broken Bones":
                return AnyView(BrokenBonesGuidanceView())
            case "Sprains":
                return AnyView(SprainsGuidanceView())
                
            // Breathing Issues subtopics
            case "Asthma Attacks":
                return AnyView(AsthmaGuidanceView())
            case "Hyperventilation":
                return AnyView(HyperventilationGuidanceView())
                
            // Medical & Poisoning subtopics
            case "Diabetic Emergencies":
                return AnyView(DiabeticEmergencyView())
            case "Food Poisoning":
                return AnyView(FoodPoisoningView())
            case "Alcohol Poisoning":
                return AnyView(AlcoholPoisoningView())
                
            // Environmental subtopics
            case "Heatstroke":
                return AnyView(HeatstrokeGuidanceView())
            case "Hypothermia":
                return AnyView(HypothermiaGuidanceView())
                
            default:
                return AnyView(destinationView(for: result.mainTopic))
            }
        } else {
            // For main topics, show the category view
            return AnyView(destinationView(for: result.mainTopic))
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
}

struct SubtopicCard: View {
    let result: HomeContentView.SearchResult
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16
        let horizontalPadding: CGFloat = 16
        let cardSize = (screenWidth - (horizontalPadding * 2) - spacing) / 2
        
        VStack(alignment: .center, spacing: 16) {
            Spacer(minLength: 16)
            
            // Icon Circle
            ZStack {
                Circle()
                    .fill(result.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: result.icon)
                    .font(.system(size: 24))
                    .foregroundColor(result.color)
            }
            
            // Title and Subtitle
            VStack(alignment: .center, spacing: 4) {
                Text(result.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                
                Text(result.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)
            
            Spacer(minLength: 16)
        }
        .frame(width: cardSize, height: cardSize)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: result.color.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(result.color.opacity(0.2), lineWidth: 1)
        )
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
    let subtopicKeywords: [String: [String]]
}

// Emergency Card Component
struct EmergencyTopicCard: View {
    let topic: EmergencyTopic
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16
        let horizontalPadding: CGFloat = 16
        let cardSize = (screenWidth - (horizontalPadding * 2) - spacing) / 2
        
        VStack(alignment: .center, spacing: 16) {
            Spacer(minLength: 16)
            
            // Icon Circle
            ZStack {
                Circle()
                    .fill(topic.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: topic.icon)
                    .font(.system(size: 24))
                    .foregroundColor(topic.color)
            }
            
            // Title and subtitle
            VStack(alignment: .center, spacing: 4) {
                Text(topic.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                
                Text(topic.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)
            
            Spacer(minLength: 16)
        }
        .frame(width: cardSize, height: cardSize)
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
                .stroke(topic.color.opacity(0.15), lineWidth: 1)
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
                    .foregroundColor(selectedTab == index ? .teal : .gray)
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
    static let shared = NetworkMonitor()
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
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        Group {
            if networkMonitor.isConnected {
                // Keep a clear background but immediately show sheet when connected
                Color.clear
                    .sheet(isPresented: $showingSymptomChecker) {
                        SymptomCheckerView()
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(false)
                            .onDisappear {
                                if selectedTab == 1 {
                                    selectedTab = 0
                                }
                            }
                    }
            } else {
                // Offline message
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Symptom Checker Unavailable")
                        .font(.title2)
                        .bold()
                    
                    Text("Please check your internet connection to use the Symptom Checker feature.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        // Handle tab selection
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 && networkMonitor.isConnected {
                showingSymptomChecker = true
            }
        }
        // Handle network state changes
        .onChange(of: networkMonitor.isConnected) { wasConnected, isConnected in
            if isConnected && selectedTab == 1 {
                showingSymptomChecker = true
            }
        }
        // Ensure sheet is shown when view appears if we're on the symptoms tab and connected
        .onAppear {
            if selectedTab == 1 && networkMonitor.isConnected {
                showingSymptomChecker = true
            }
        }
    }
}

// Add color extension at the end of the file
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}