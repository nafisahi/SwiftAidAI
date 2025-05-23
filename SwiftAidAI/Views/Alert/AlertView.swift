import SwiftUI
import HealthKit
import MapKit
import Contacts
import Foundation
import MessageUI

// Model for storing emergency contact information
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

// Model for tracking alert status
struct AlertStatus {
    var isLocationShared: Bool
    var contactsNotified: Int
}

// Main emergency alert view with health monitoring and contact management
struct AlertView: View {
    // View models and state management
    @StateObject private var viewModel = AlertViewModel()
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var messageHelper = EmergencyMessageHelper()
    @State private var showingHospitalMap = false
    @State private var messageVC: MFMessageComposeViewController?
    @State private var showingMessageSheet = false
    @State private var showingSMSError = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header with title and subtitle
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
                
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Emergency Actions Section with call buttons and hospital finder
                        VStack(spacing: 16) {
                            // Emergency Call Buttons (999 and 112)
                            HStack(spacing: 12) {
                                // 999 Emergency Button
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
                                
                                // 112 Emergency Button
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
                            
                            // Hospital Finder Button
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
                        
                        // Health Status Section with metrics
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
                                // Heart Rate Metric Card
                                HealthMetricCard(
                                    title: "Heart Rate",
                                    value: "\(Int(viewModel.healthMetrics.heartRate))",
                                    unit: "BPM",
                                    icon: "heart.fill",
                                    status: viewModel.getHeartRateStatus(viewModel.healthMetrics.heartRate)
                                )
                                
                                // Steps Metric Card
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
                        
                        // Emergency Alert Button Section
                        VStack(spacing: 8) {
                            Button(action: {
                                if viewModel.emergencyContacts.isEmpty {
                                    viewModel.showingNoContactsAlert = true
                                } else {
                                    viewModel.showingAlertConfirmation = true
                                }
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
                                
                                // Add Contact Button
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
                            
                            // Empty State or Contact List
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
                            
                            // Contact Count and Info
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
        // View Lifecycle and Event Handlers
        .onAppear {
            viewModel.requestHealthData()
        }
        // Emergency Alert Confirmation Dialog
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
        // SMS Error Alert
        .alert("SMS Not Available", isPresented: $showingSMSError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("SMS messaging is not available on this device. Please check your settings.")
        }
        // Message Sheet for Emergency Alert
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
        // Contacts Permission Alert
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
        // Contact Picker Sheet
        .sheet(isPresented: $viewModel.showingContactPicker) {
            ContactPicker(
                onSelect: { name, number in
                    let newContact = EmergencyContact(name: name, phoneNumber: number, isSelected: true)
                    viewModel.addContact(newContact)
                },
                selectedCount: viewModel.emergencyContacts.count
            )
        }
        // Hospital Map Sheet
        .sheet(isPresented: $showingHospitalMap) {
            EmergencyAlertView()
        }
        // Contact Deletion Confirmation
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
        // No Contacts Alert
        .alert("No Emergency Contacts", isPresented: $viewModel.showingNoContactsAlert) {
            Button("Add Contacts", role: .none) {
                viewModel.requestContactPermission()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You haven't added any emergency contacts yet. Would you like to add contacts who will be notified in case of an emergency?")
        }
    }
}

// Card for displaying health metrics
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

// Card for displaying alert status
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

// Row for displaying status information
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

// Row for displaying emergency contact information
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

// Enum for health status indicators
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

// Header component for sections
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

