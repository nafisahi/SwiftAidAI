import SwiftUI 
import HealthKit 


struct HealthMetrics {
    var heartRate: Double
    var bloodOxygen: Double
    var respirationRate: Double
    var stepCount: Int
}

struct AlertStatus {
    var isLocationShared: Bool
    var contactsNotified: Int
}

// MARK: - ViewModel
class AlertViewModel: ObservableObject {
    @Published var healthMetrics: HealthMetrics
    @Published var alertStatus: AlertStatus
    @Published var autoAlertEnabled: Bool
    @Published var showingAlertConfirmation: Bool
    
    init() {
        self.healthMetrics = HealthMetrics(
            heartRate: 75.0,
            bloodOxygen: 98.0,
            respirationRate: 16.0,
            stepCount: 5432
        )
        self.alertStatus = AlertStatus(
            isLocationShared: false,
            contactsNotified: 0
        )
        self.autoAlertEnabled = false
        self.showingAlertConfirmation = false
    }
    
    // Health status calculations
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
    
    // Alert actions
    func sendEmergencyAlert() {
        alertStatus.isLocationShared = true
        alertStatus.contactsNotified += 1
    }
}

// MARK: - View
struct AlertView: View {
    @StateObject private var viewModel = AlertViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation area with blur effect
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Text("Emergency Alert")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
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
                
                ScrollView {
                    VStack(spacing: 24) {
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
                                value: "\(Int(viewModel.healthMetrics.heartRate))",
                                unit: "BPM",
                                icon: "heart.fill",
                                status: viewModel.getHeartRateStatus(viewModel.healthMetrics.heartRate)
                            )
                            
                            HealthMetricCard(
                                title: "Blood Oxygen",
                                value: "\(Int(viewModel.healthMetrics.bloodOxygen))",
                                unit: "%",
                                icon: "lungs.fill",
                                status: viewModel.getOxygenStatus(viewModel.healthMetrics.bloodOxygen)
                            )
                            
                            HealthMetricCard(
                                title: "Respiration",
                                value: "\(Int(viewModel.healthMetrics.respirationRate))",
                                unit: "/ min",
                                icon: "wind",
                                status: viewModel.getRespirationStatus(viewModel.healthMetrics.respirationRate)
                            )
                            
                            HealthMetricCard(
                                title: "Steps",
                                value: "\(viewModel.healthMetrics.stepCount)",
                                unit: "steps",
                                icon: "figure.walk",
                                status: .normal
                            )
                        }
                        .padding(.horizontal)
                        
                        // Emergency Alert Button
                        Button(action: {
                            viewModel.showingAlertConfirmation = true
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
                        .alert("Send Emergency Alert", isPresented: $viewModel.showingAlertConfirmation) {
                            Button("Cancel", role: .cancel) { }
                            Button("Send Alert", role: .destructive) {
                                viewModel.sendEmergencyAlert()
                            }
                        } message: {
                            Text("This will send your location and vital signs to your emergency contacts.")
                        }
                        
                        // Auto-alert Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Auto-alert when vitals are abnormal", isOn: $viewModel.autoAlertEnabled)
                                .tint(.blue)
                            
                            Text("Will send alert if your heart rate or oxygen level is unsafe")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
    }
}

// MARK: - Supporting Views
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

#Preview {
    AlertView()
} 
