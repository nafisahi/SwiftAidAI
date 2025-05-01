import HealthKit

class HealthManager {
    // HealthKit store instance for accessing health data
    let healthStore = HKHealthStore()
    
    // HealthKit quantity types for heart rate and step count
    var heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    var stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    // Observers and timer for real-time health data monitoring
    private var heartRateObserver: HKObserverQuery?
    private var stepCountObserver: HKObserverQuery?
    private var heartRateTimer: Timer?
    
    // Callback for heart rate updates
    var onHeartRateUpdate: ((Double) -> Void)?
    
    // Reference to AlertViewModel for checking autoAlertEnabled
    weak var alertViewModel: AlertViewModel?
    
    // Thresholds for heart rate alerts
    let highHeartRateThreshold: Double = 100
    let lowHeartRateThreshold: Double = 50
    
    // Notification cooldown management
    private var lastNotificationTime: Date?
    private let notificationCooldown: TimeInterval = 120 // 2 minutes cooldown
    
    init(alertViewModel: AlertViewModel) {
        self.alertViewModel = alertViewModel
    }
    
    // Clean up resources when the manager is deallocated
    deinit {
        stopObserving()
    }
    
    // Check if enough time has passed since the last notification
    private func canSendNotification() -> Bool {
        guard let lastTime = lastNotificationTime else { return true }
        return Date().timeIntervalSince(lastTime) >= notificationCooldown
    }
    
    // Check if notifications are enabled
    private func shouldSendNotifications() -> Bool {
        return alertViewModel?.autoAlertEnabled == true
    }
    
    // Check heart rate status
    private func checkHeartRateStatus(_ bpm: Double) -> HeartRateStatus {
        if bpm > highHeartRateThreshold {
            return .high(bpm)
        } else if bpm < lowHeartRateThreshold {
            return .low(bpm)
        }
        return .normal(bpm)
    }
    
    // Request user authorization to access health data
    // This is required before any health data can be accessed
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToRead: Set = [heartRateType, stepCountType]
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.startObserving()
                }
                completion(success)
            }
        }
    }
    
    // Initialize real-time monitoring of health data
    // Sets up observers for heart rate and step count changes
    func startObserving() {
        // Heart Rate Observer - triggers when new heart rate data is available
        let heartRateObserver = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchLatestHeartRate { bpm in
                    if let bpm = bpm {
                        self?.onHeartRateUpdate?(bpm)
                    }
                }
            }
        }
        healthStore.execute(heartRateObserver)
        self.heartRateObserver = heartRateObserver
        
        // Step Count Observer - triggers when step count changes
        let stepCountObserver = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchTodayStepCount { _ in }
            }
        }
        healthStore.execute(stepCountObserver)
        self.stepCountObserver = stepCountObserver
        
        // Enable background delivery for real-time updates even when app is in background
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
        healthStore.enableBackgroundDelivery(for: stepCountType, frequency: .immediate) { _, _ in }
        
        // Backup timer for heart rate updates in case observer fails
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchLatestHeartRate { bpm in
                if let bpm = bpm {
                    self?.onHeartRateUpdate?(bpm)
                }
            }
        }
    }
    
    // Stop all health data monitoring and cleanup resources
    func stopObserving() {
        if let observer = heartRateObserver {
            healthStore.stop(observer)
        }
        if let observer = stepCountObserver {
            healthStore.stop(observer)
        }
        heartRateTimer?.invalidate()
        heartRateTimer = nil
    }
    
    // Fetch the most recent heart rate reading from the last hour
    func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        let now = Date()
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: oneHourAgo, end: now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, 
                                predicate: predicate,
                                limit: 1,
                                sortDescriptors: [sort]) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    completion(nil)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: .init(from: "count/min"))
                
                // Check heart rate status and send notification if needed
                if self?.shouldSendNotifications() == true && self?.canSendNotification() == true {
                    switch self?.checkHeartRateStatus(bpm) {
                    case .high:
                        NotificationManager.shared.sendHighHeartRateNotification(current: bpm)
                        self?.lastNotificationTime = Date()
                    case .low:
                        NotificationManager.shared.sendLowHeartRateNotification(current: bpm)
                        self?.lastNotificationTime = Date()
                    default:
                        break
                    }
                }
                
                completion(bpm)
            }
        }
        healthStore.execute(query)
    }

    // Fetch the total number of steps taken today
    func fetchTodayStepCount(completion: @escaping (Int) -> Void) {
        guard let startOfDay = Calendar.current.startOfDay(for: Date()) as Date? else {
            completion(0)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(0)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                completion(Int(steps))
            }
        }
        healthStore.execute(query)
    }
}

enum HeartRateStatus {
    case normal(Double)
    case high(Double)
    case low(Double)
} 