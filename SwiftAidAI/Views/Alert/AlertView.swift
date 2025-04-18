import SwiftUI
import HealthKit
import MapKit
import Contacts
import Foundation
import MessageUI

// MARK: - Models
struct HealthMetrics {
    var heartRate: Double
    var stepCount: Int
}

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var isSelected: Bool
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.isSelected = isSelected
    }
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
    @Published var emergencyContacts: [EmergencyContact] {
        didSet {
            saveContacts()
        }
    }
    @Published var showingContactPicker: Bool
    @Published var showingPermissionAlert: Bool
    @Published var contactToDelete: EmergencyContact?
    @Published var showingDeleteConfirmation: Bool = false
    let maxContacts = 3
    
    private let contactService = EmergencyContactService()
    
    init() {
        self.healthMetrics = HealthMetrics(
            heartRate: 75.0,
            stepCount: 5432
        )
        self.alertStatus = AlertStatus(
            isLocationShared: false,
            contactsNotified: 0
        )
        self.autoAlertEnabled = false
        self.showingAlertConfirmation = false
        self.showingContactPicker = false
        self.showingPermissionAlert = false
        self.emergencyContacts = []
        
        // Load saved contacts
        loadContacts()
    }
    
    // Health status calculations
    func getHeartRateStatus(_ rate: Double) -> HealthStatus {
        if rate > 120 || rate < 50 { return .critical }
        if rate > 100 || rate < 60 { return .warning }
        return .normal
    }
    
    // Alert actions
    func sendEmergencyAlert() {
        alertStatus.isLocationShared = true
        alertStatus.contactsNotified = emergencyContacts.filter { $0.isSelected }.count
    }
    
    // Contact management
    func canAddMoreContacts() -> Bool {
        return emergencyContacts.count < maxContacts
    }
    
    func addContact(_ contact: EmergencyContact) {
        if emergencyContacts.count < maxContacts {
            emergencyContacts.append(contact)
            saveContacts()
        }
    }
    
    func removeContact(_ contact: EmergencyContact) {
        emergencyContacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    func toggleContactSelection(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index].isSelected.toggle()
            saveContacts()
        }
    }
    
    func requestContactPermission() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.showingContactPicker = true
                } else {
                    self.showingPermissionAlert = true
                }
            }
        }
    }
    
    func confirmDelete(_ contact: EmergencyContact) {
        contactToDelete = contact
        showingDeleteConfirmation = true
    }
    
    func deleteConfirmedContact() {
        if let contact = contactToDelete {
            removeContact(contact)
            contactToDelete = nil
        }
    }
    
    private func saveContacts() {
        contactService.saveContacts(emergencyContacts)
    }
    
    private func loadContacts() {
        contactService.loadContacts { [weak self] contacts in
            DispatchQueue.main.async {
                self?.emergencyContacts = contacts
            }
        }
    }
}

// MARK: - View
struct AlertView: View {
    @StateObject private var viewModel = AlertViewModel()
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var messageHelper = EmergencyMessageHelper()
    @State private var showingHospitalMap = false
    @State private var messageVC: MFMessageComposeViewController?
    @State private var showingMessageSheet = false
    @State private var showingSMSError = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header
                VStack(spacing: 8) {
                    Text("Emergency Alert")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Choose your emergency response")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 16)
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
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Emergency Actions Section
                        VStack(spacing: 16) {
                            // Emergency Call Buttons
                            HStack(spacing: 12) {
                                // 999 Button
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("999")
                                    }
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.red)
                                    .cornerRadius(12)
                                }
                                
                                // 112 Button
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("112")
                                    }
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Hospital Button
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    locationViewModel.findHospitals()
                                    showingHospitalMap = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "cross.case.fill")
                                        Text("Find Nearest Hospital")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.teal)
                                    .cornerRadius(12)
                                }
                                
                                Text("Shows nearby emergency centers using your location.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                        
                        // Health Status Section
                        VStack(spacing: 16) {
                            Text("Health Status")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
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
                                    title: "Steps",
                                    value: "\(viewModel.healthMetrics.stepCount)",
                                    unit: "steps",
                                    icon: "figure.walk",
                                    status: .normal
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Emergency Alert Button
                        VStack(spacing: 8) {
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
                            
                            Text("This will notify your emergency contacts and share your location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Emergency Contacts Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Emergency Contacts")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                if viewModel.canAddMoreContacts() {
                                    Button(action: {
                                        viewModel.requestContactPermission()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                            .frame(width: 44, height: 44)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.emergencyContacts.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.2.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No emergency contacts added")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Tap + to add contacts who will receive emergency alerts")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.emergencyContacts) { contact in
                                        ContactRow(
                                            contact: contact,
                                            onDelete: { viewModel.confirmDelete(contact) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack {
                                Text("\(viewModel.emergencyContacts.count)/\(viewModel.maxContacts) contacts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("All contacts will receive emergency alerts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Auto-alert Settings Section
                        VStack(spacing: 16) {
                            SectionHeader(title: "Auto-alert Settings", icon: "gear")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Auto-alert when vitals are abnormal", isOn: $viewModel.autoAlertEnabled)
                                    .tint(.blue)
                                
                                Text("Will send alert if your heart rate is unsafe")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .alert("Send Emergency Alert", isPresented: $viewModel.showingAlertConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Send Alert", role: .destructive) {
                messageHelper.generateMessage(name: "User", contacts: viewModel.emergencyContacts) { vc in
                    if let vc = vc {
                        self.messageVC = vc
                        self.showingMessageSheet = true
                    } else {
                        self.showingSMSError = true
                    }
                }
            }
        } message: {
            Text("This will send your location and vital signs to your emergency contacts.")
        }
        .alert("SMS Not Available", isPresented: $showingSMSError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("SMS messaging is not available on this device. Please check your settings.")
        }
        .fullScreenCover(isPresented: $showingMessageSheet) {
            if let vc = messageVC {
                MessageSheetController(messageVC: vc, isPresented: $showingMessageSheet)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: showingMessageSheet) { newValue in
            if !newValue {
                messageVC = nil
            }
        }
        .alert("Contacts Access Required", isPresented: $viewModel.showingPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable contacts access in Settings to add emergency contacts.")
        }
        .sheet(isPresented: $viewModel.showingContactPicker) {
            ContactPicker(
                onSelect: { name, number in
                    let newContact = EmergencyContact(name: name, phoneNumber: number, isSelected: true)
                    viewModel.addContact(newContact)
                },
                selectedCount: viewModel.emergencyContacts.count
            )
        }
        .sheet(isPresented: $showingHospitalMap) {
            EmergencyAlertView()
        }
        .alert("Remove Contact", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                viewModel.contactToDelete = nil
            }
            Button("Remove", role: .destructive) {
                viewModel.deleteConfirmedContact()
            }
        } message: {
            if let contact = viewModel.contactToDelete {
                Text("Are you sure you want to remove \(contact.name) from your emergency contacts?")
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

struct ContactRow: View {
    let contact: EmergencyContact
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Contact Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                Text(contact.name.prefix(1).uppercased())
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    AlertView()
}

