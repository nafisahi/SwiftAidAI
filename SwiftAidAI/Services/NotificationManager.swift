import UserNotifications

// Manages all notification-related functionality for the app
class NotificationManager {
    // One copy of NotificationManager that can be used everywhere
    static let shared = NotificationManager()
    
    // Private init to ensure singleton pattern
    private init() {
        setupNotificationCategories()
    }
    
    // Sets up the notification actions and categories
    private func setupNotificationCategories() {
        // Create an action button for sending emergency alerts
        let emergencyAction = UNNotificationAction(
            identifier: "SEND_EMERGENCY_ALERT",
            title: "Tap here to send emergency alert",
            options: [.foreground, .destructive]
        )
        
        // Create a category for heart rate alerts with the emergency action
        let heartRateCategory = UNNotificationCategory(
            identifier: "HEART_RATE_ALERT",
            actions: [emergencyAction],
            intentIdentifiers: [],
            options: [.hiddenPreviewsShowTitle]
        )
        
        // Register the category with the notification system
        UNUserNotificationCenter.current().setNotificationCategories([heartRateCategory])
    }
    
    // Request permission to send notifications from the user
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                // Notification permission granted
            } else if let error = error {
                // Error requesting notification permission
            }
        }
    }
    
    // Send a notification when heart rate is too high
    func sendHighHeartRateNotification(current: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 High Heart Rate Alert"
        content.subtitle = "\(Int(current)) BPM Detected"
        content.body = "Your heart rate is significantly elevated. Tap below if you need immediate assistance."
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "HEART_RATE_ALERT"
        content.threadIdentifier = "health_alerts"
        
        // Create and schedule the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Send a notification when heart rate is too low
    func sendLowHeartRateNotification(current: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Low Heart Rate Alert"
        content.subtitle = "\(Int(current)) BPM Detected"
        content.body = "Your heart rate is dangerously low. Tap below if you need immediate assistance."
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "HEART_RATE_ALERT"
        content.threadIdentifier = "health_alerts"
        
        // Create and schedule the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
} 