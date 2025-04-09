import SwiftUI
import HealthKit

struct AlertView: View {
    @State private var autoAlertEnabled = false
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showingAlertConfirmation = false
    
    // Sample health data states (replace with actual HealthKit data)
    @State private var heartRate = 75.0
    @State private var bloodOxygen = 98.0
    @State private var respirationRate = 16.0
    @State private var stepCount = 5432
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emergency Alert")
                        .font(.system(size: 34, weight: .bold))
                    Text("Track your health and send help when it's needed most.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Emergency Call Buttons
                SharedEmergencyCallButtons()
                    .padding(.horizontal)
                
                // Health Metrics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    HealthMetricCard(
                        title: "Heart Rate",
                        value: "\(Int(heartRate))",
                        unit: "BPM",
                        icon: "heart.fill",
                        status: healthKitManager.getHeartRateStatus(heartRate)
                    )
                    
                    HealthMetricCard(
                        title: "Blood Oxygen",
                        value: "\(Int(bloodOxygen))",
                        unit: "%",
                        icon: "lungs.fill",
                        status: healthKitManager.getOxygenStatus(bloodOxygen)
                    )
                    
                    HealthMetricCard(
                        title: "Respiration",
                        value: "\(Int(respirationRate))",
                        unit: "/ min",
                        icon: "wind",
                        status: healthKitManager.getRespirationStatus(respirationRate)
                    )
                    
                    HealthMetricCard(
                        title: "Steps",
                        value: "\(stepCount)",
                        unit: "steps",
                        icon: "figure.walk",
                        status: .normal
                    )
                }
                .padding(.horizontal)
                
                // Emergency Alert Button
                Button(action: {
                    showingAlertConfirmation = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Send Emergency Alert")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .alert("Send Emergency Alert", isPresented: $showingAlertConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Send Alert", role: .destructive) {
                        healthKitManager.sendEmergencyAlert()
                    }
                } message: {
                    Text("This will send your location and vital signs to your emergency contacts.")
                }
                
                // Auto-alert Toggle
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Auto-alert when vitals are abnormal", isOn: $autoAlertEnabled)
                        .tint(.blue)
                    
                    Text("Will send alert if your heart rate or oxygen level is unsafe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Status Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        StatusRow(
                            icon: "location.fill",
                            title: "Location Shared",
                            status: healthKitManager.isLocationShared ? "Active" : "Inactive",
                            color: healthKitManager.isLocationShared ? .green : .secondary
                        )
                        
                        StatusRow(
                            icon: "person.2.fill",
                            title: "Contacts Notified",
                            status: "\(healthKitManager.contactsNotified)",
                            color: healthKitManager.contactsNotified > 0 ? .blue : .secondary
                        )
                        
                        StatusRow(
                            icon: "waveform.path.ecg",
                            title: "Monitoring",
                            status: autoAlertEnabled ? "Active" : "Inactive",
                            color: autoAlertEnabled ? .green : .secondary
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct HealthMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let status: HealthStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(status.color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct StatusCard: View {
    let isLocationShared: Bool
    let contactsNotified: Int
    let isMonitoring: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.headline)
            
            StatusRow(
                icon: "location.fill",
                title: "Location Shared",
                status: isLocationShared ? "Active" : "Inactive",
                color: isLocationShared ? .green : .secondary
            )
            
            StatusRow(
                icon: "person.2.fill",
                title: "Contacts Notified",
                status: "\(contactsNotified)",
                color: contactsNotified > 0 ? .blue : .secondary
            )
            
            StatusRow(
                icon: "waveform.path.ecg",
                title: "Monitoring",
                status: isMonitoring ? "Active" : "Inactive",
                color: isMonitoring ? .green : .secondary
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusRow: View {
    let icon: String
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
            Spacer()
            Text(status)
                .foregroundColor(color)
        }
    }
}

enum HealthStatus {
    case critical, warning, normal
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .warning: return .orange
        case .normal: return .green
        }
    }
}

// HealthKit Manager (stub implementation)
class HealthKitManager: ObservableObject {
    @Published var isLocationShared = false
    @Published var contactsNotified = 0
    
    func getHeartRateStatus(_ rate: Double) -> HealthStatus {
        if rate > 120 || rate < 50 { return .critical }
        if rate > 100 || rate < 60 { return .warning }
        return .normal
    }
    
    func getOxygenStatus(_ level: Double) -> HealthStatus {
        if level < 90 { return .critical }
        if level < 95 { return .warning }
        return .normal
    }
    
    func getRespirationStatus(_ rate: Double) -> HealthStatus {
        if rate > 30 || rate < 8 { return .critical }
        if rate > 25 || rate < 12 { return .warning }
        return .normal
    }
    
    func sendEmergencyAlert() {
        // Implement actual emergency alert logic
        isLocationShared = true
        contactsNotified += 1
    }
}

#Preview {
    AlertView()
} 