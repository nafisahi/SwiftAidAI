import Foundation
import SwiftUI
import Contacts
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

// Stores health data like heart rate and steps
struct HealthMetrics {
    var heartRate: Double = 0
    var stepCount: Int = 0
}

// Manages emergency alerts and contacts
class AlertViewModel: ObservableObject {
    // Current health data
    @Published var healthMetrics = HealthMetrics()
    
    // Alert status showing if location is shared and how many contacts were notified
    @Published var alertStatus = AlertStatus(isLocationShared: false, contactsNotified: 0)
    
    // Settings for automatic alerts
    @Published var autoAlertEnabled = false {
        didSet {
            if autoAlertEnabled {
                NotificationManager.shared.requestPermission()
            }
            saveSettings()
        }
    }
    
    // UI state flags
    @Published var showingAlertConfirmation = false
    @Published var showingNoContactsAlert = false
    
    // List of emergency contacts
    @Published var emergencyContacts: [EmergencyContact] = [] {
        didSet {
            saveContacts()
        }
    }
    
    // More UI state flags
    @Published var showingContactPicker = false
    @Published var showingPermissionAlert = false
    @Published var contactToDelete: EmergencyContact?
    @Published var showingDeleteConfirmation = false
    
    // Maximum number of emergency contacts allowed
    let maxContacts = 3
    
    // Services for health data and contact management
    private lazy var healthManager: HealthManager = {
        let manager = HealthManager(alertViewModel: self)
        return manager
    }()
    private let contactService = EmergencyContactService()
    
    // Loading saved contacts and settings, setting up health monitoring and notification handling
    init() {
        loadContacts()
        loadSettings()
        setupHealthMonitoring()
        setupNotificationHandling()
    }
    
    // Clean up when view model is destroyed
    deinit {
        healthManager.stopObserving()
    }
    
    // Set up health monitoring and callbacks
    private func setupHealthMonitoring() {
        healthManager.onHeartRateUpdate = { [weak self] bpm in
            DispatchQueue.main.async {
                self?.healthMetrics.heartRate = bpm
            }
        }
        requestHealthData()
    }
    
    // Request access to health data
    func requestHealthData() {
        healthManager.requestAuthorization { granted in
            if granted {
                self.fetchHealthMetrics()
            }
        }
    }
    
    // Get latest heart rate and step count
    func fetchHealthMetrics() {
        healthManager.fetchLatestHeartRate { bpm in
            DispatchQueue.main.async {
                if let bpm = bpm {
                    self.healthMetrics.heartRate = bpm
                } else {
                    // No recent heart rate data available
                    self.healthMetrics.heartRate = 0
                }
            }
        }
        
        healthManager.fetchTodayStepCount { steps in
            DispatchQueue.main.async {
                self.healthMetrics.stepCount = steps
            }
        }
    }
    
    // Check if heart rate is normal, warning, or critical
    func getHeartRateStatus(_ rate: Double) -> HealthStatus {
        if rate > 120 || rate < 50 { return .critical }
        if rate > 100 || rate < 60 { return .warning }
        return .normal
    }
    
    // Send emergency alert to selected contacts
    func sendEmergencyAlert() {
        alertStatus.isLocationShared = true
        alertStatus.contactsNotified = emergencyContacts.filter { $0.isSelected }.count
    }
    
    // Check if more contacts can be added
    func canAddMoreContacts() -> Bool {
        return emergencyContacts.count < maxContacts
    }
    
    // Add a new emergency contact
    func addContact(_ contact: EmergencyContact) {
        if emergencyContacts.count < maxContacts {
            emergencyContacts.append(contact)
            saveContacts()
        }
    }
    
    // Remove an emergency contact
    func removeContact(_ contact: EmergencyContact) {
        emergencyContacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
    
    // Toggle whether a contact should be notified in emergencies
    func toggleContactSelection(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index].isSelected.toggle()
            saveContacts()
        }
    }
    
    // Ask for permission to access contacts
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
    
    // Show confirmation before deleting a contact
    func confirmDelete(_ contact: EmergencyContact) {
        contactToDelete = contact
        showingDeleteConfirmation = true
    }
    
    // Delete a contact after confirmation
    func deleteConfirmedContact() {
        if let contact = contactToDelete {
            removeContact(contact)
            contactToDelete = nil
        }
    }
    
    // Save contacts to persistent storage
    private func saveContacts() {
        contactService.saveContacts(emergencyContacts)
    }
    
    // Load saved contacts from storage
    private func loadContacts() {
        contactService.loadContacts { [weak self] contacts in
            DispatchQueue.main.async {
                self?.emergencyContacts = contacts
            }
        }
    }
    
    // Set up notification handling
    private func setupNotificationHandling() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationDelegate.shared.onEmergencyAlert = { [weak self] in
            self?.sendEmergencyAlert()
        }
    }
    
    // Save settings to Firestore
    private func saveSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let settingsData: [String: Any] = [
            "autoAlertEnabled": autoAlertEnabled
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("settings")
            .document("alert_settings")
            .setData(settingsData) { error in
                if let error = error {
                    // Error saving settings
                }
            }
    }
    
    // Load settings from Firestore
    private func loadSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("settings")
            .document("alert_settings")
            .getDocument { [weak self] document, error in
                if let error = error {
                    // Error loading settings
                    return
                }
                
                if let data = document?.data(),
                   let autoAlertEnabled = data["autoAlertEnabled"] as? Bool {
                    DispatchQueue.main.async {
                        self?.autoAlertEnabled = autoAlertEnabled
                    }
                }
            }
    }
}

// Notification delegate to handle notification actions
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    var onEmergencyAlert: (() -> Void)?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "SEND_EMERGENCY_ALERT" {
            onEmergencyAlert?()
        }
        completionHandler()
    }
} 