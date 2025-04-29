import SwiftUI 
import Network
import UserNotifications

// Main view for the First Aid application that handles tab-based navigation
struct FirstAidHomeView: View {
    @State private var selectedTab = 0
    @State private var showingNotificationPermission = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Aid Tab - Main home screen with emergency categories
            NavigationStack {
                HomeContentView()
            }
            .tabItem {
                Label("First Aid", systemImage: "cross.case.fill")
            }
            .tag(0)
            .tint(.teal)
            
            // Symptoms Tab - AI-powered symptom checker
            SymptomCheckerTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Symptoms", systemImage: "stethoscope")
                }
                .tag(1)
                .tint(.teal)
            
            // Alert Tab - Emergency alerts and notifications
            AlertView()
                .tabItem {
                    Label("Alert", systemImage: "bell.fill")
                }
                .tag(2)
                .tint(.teal)
        }
        .onAppear {
            // Configure tab bar appearance with teal accent color
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.teal)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.teal)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
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
    
    // Request user permission for sending notifications
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

// Main content view for the First Aid tab, displaying emergency categories and search functionality
struct HomeContentView: View {
    @State private var searchText = ""
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var showingProfile = false
    
    // Two-column grid layout for emergency topics
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Comprehensive list of first aid topics with their subtopics and search keywords
    let allFirstAidTopics: [FirstAidTopic] = [
        // Critical Emergencies
        FirstAidTopic(
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
            id: UUID(),
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
    
    // Search result model for displaying filtered topics and subtopics
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
    
    // Computed property that filters topics based on search text
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
            // Match main topics
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
            
            // Match subtopics and their keywords
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
                // Header with profile button and offline mode banner
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
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .sheet(isPresented: $showingProfile) {
                        ProfileView()
                    }
                    
                    // Display offline mode banner when no internet connection
                    if !networkMonitor.isConnected {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text("Offline Mode: You can still access first aid guides.")
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
                        // Search bar with clear button
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
                        
                        // Grid of topics or search results
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(searchResults) { result in
                                NavigationLink(destination: destinationView(for: result)) {
                                    if result.isSubtopic {
                                        SubtopicCard(result: result)
                                    } else {
                                        TopicCard(topic: FirstAidTopic(
                                            id: UUID(),
                                            category: result.category,
                                            title: result.title,
                                            subtitle: result.subtitle,
                                            icon: result.icon,
                                            color: result.color,
                                            subtopics: [],
                                            subtopicKeywords: [:]
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
    
    // Navigate to appropriate view based on selected topic or subtopic
    private func destinationView(for result: SearchResult) -> some View {
        if result.isSubtopic {
            // Return specific guidance view based on subtopic
            switch result.title {
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
                
            case "Minor Cuts and Grazes":
                return AnyView(CutsAndGrazesGuidanceView())
            case "Nosebleeds":
                return AnyView(NosebleedGuidanceView())
            case "Blisters":
                return AnyView(BlisterGuidanceView())
                
            case "Chemical Burns":
                return AnyView(ChemicalBurnsGuidanceView())
            case "Severe Burns":
                return AnyView(SevereBurnsGuidanceView())
            case "Minor Burns":
                return AnyView(MinorBurnsGuidanceView())
            case "Sunburn":
                return AnyView(SunburnGuidanceView())
                
            case "Broken Bones":
                return AnyView(BrokenBonesGuidanceView())
            case "Sprains":
                return AnyView(SprainsGuidanceView())
                
            case "Asthma Attacks":
                return AnyView(AsthmaGuidanceView())
            case "Hyperventilation":
                return AnyView(HyperventilationGuidanceView())
                
            case "Diabetic Emergencies":
                return AnyView(DiabeticEmergencyView())
            case "Food Poisoning":
                return AnyView(FoodPoisoningView())
            case "Alcohol Poisoning":
                return AnyView(AlcoholPoisoningView())
                
            case "Heatstroke":
                return AnyView(HeatstrokeGuidanceView())
            case "Hypothermia":
                return AnyView(HypothermiaGuidanceView())
                
            default:
                return AnyView(destinationView(for: result.mainTopic))
            }
        } else {
            // Return category view for main topics
            return AnyView(destinationView(for: result.mainTopic))
        }
    }
    
    // Navigate to appropriate category view
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

// Card view for displaying subtopics
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

// Data model for first aid topics
struct FirstAidTopic: Identifiable {
    let id: UUID
    let category: EmergencyCategory
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let subtopics: [String]
    let subtopicKeywords: [String: [String]]
}

// Card view for displaying main topics
struct TopicCard: View {
    let topic: FirstAidTopic
    
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

// Categories for organizing first aid topics
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

// Network connectivity monitor
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

// Preview provider
#Preview {
    FirstAidHomeView()
}

// View for the Symptom Checker tab
struct SymptomCheckerTabView: View {
    @State private var showingSymptomChecker = false
    @Binding var selectedTab: Int
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        Group {
            if networkMonitor.isConnected {
                // Show symptom checker when connected
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
                // Show offline message when not connected
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
        // Handle tab selection and network state changes
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 && networkMonitor.isConnected {
                showingSymptomChecker = true
            }
        }
        .onChange(of: networkMonitor.isConnected) { wasConnected, isConnected in
            if isConnected && selectedTab == 1 {
                showingSymptomChecker = true
            }
        }
        .onAppear {
            if selectedTab == 1 && networkMonitor.isConnected {
                showingSymptomChecker = true
            }
        }
    }
}