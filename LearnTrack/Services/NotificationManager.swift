import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging
import SwiftUI

/// NotificationManager handles both LOCAL and PUSH notifications
/// 
/// LOCAL NOTIFICATIONS: Scheduled on-device, triggered after a time interval
/// - Example: Timer completion alert scheduled when user starts session
/// - Triggered by the device at specified time
/// 
/// PUSH NOTIFICATIONS: Server-initiated, sent via Firebase Cloud Messaging (FCM)
/// - Example: Study reminders, achievement notifications from backend
/// - Received even when app is not in use
/// - Must be sent from backend server using FCM REST API or Admin SDK
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private var appState: AppState?
    private var isInitialized = false
    private var receivedNotifications: [ReceivedNotification] = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Notification Recording
    func getReceivedNotifications() -> [ReceivedNotification] {
        return receivedNotifications
    }
    
    func clearReceivedNotifications() {
        receivedNotifications.removeAll()
    }
    
    private func recordNotification(title: String, body: String, type: String, receivedAt: Date = Date()) {
        let notification = ReceivedNotification(
            id: UUID().uuidString,
            title: title,
            body: body,
            type: type,
            receivedAt: receivedAt
        )
        receivedNotifications.insert(notification, at: 0) // Newest first
        
        // Keep only last 50 notifications
        if receivedNotifications.count > 50 {
            receivedNotifications = Array(receivedNotifications.prefix(50))
        }
    }
    
    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
    }
    
    func setAppState(_ appState: AppState) {
        self.appState = appState
    }
    
    private func setupNotificationCategories() {
        // Define notification categories with actions
        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View", options: .foreground)
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: [])
        
        // Timer/Session category
        let timerCategory = UNNotificationCategory(identifier: "TIMER_CATEGORY", actions: [viewAction, dismissAction], intentIdentifiers: [], options: [])
        
        // Reminder category
        let reminderAction = UNNotificationAction(identifier: "REMIND_LATER", title: "Remind Later", options: [])
        let reminderCategory = UNNotificationCategory(identifier: "REMINDER_CATEGORY", actions: [viewAction, reminderAction, dismissAction], intentIdentifiers: [], options: [])
        
        // Achievement category
        let shareAction = UNNotificationAction(identifier: "SHARE_ACTION", title: "Share", options: [])
        let achievementCategory = UNNotificationCategory(identifier: "ACHIEVEMENT_CATEGORY", actions: [viewAction, shareAction, dismissAction], intentIdentifiers: [], options: [])
        
        // General category
        let generalCategory = UNNotificationCategory(identifier: "GENERAL_CATEGORY", actions: [viewAction, dismissAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([timerCategory, reminderCategory, achievementCategory, generalCategory])
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Register for remote notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    // Send push notification via Firebase Cloud Messaging (server-side)
    // This is a placeholder showing the expected payload structure
    // In production, you would send this from your backend server to FCM
    func sendPushNotificationViaFCM(to token: String, title: String, body: String, notificationType: String = "general") {
        // IMPORTANT: This should be called from your backend server, not from the app
        // Use Firebase Admin SDK or FCM REST API
        
        print(" [BACKEND] Sending push notification to token: \(token)")
        
        // Expected FCM payload structure:
        let fcmPayload: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "sound": "default"
            ],
            "data": [
                "notificationType": notificationType,
                "sentAt": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        print(" FCM Payload: \(fcmPayload)")
        print(" Note: Send this payload from your backend server using Firebase Admin SDK or FCM REST API")
        print("   Backend endpoint: https://fcm.googleapis.com/fcm/send")
        print("   Authorization header: Key=YOUR_SERVER_API_KEY")
    }
    
    // Send push notification via Firebase (placeholder - implement server-side)
    func sendPushNotification(to token: String, title: String, body: String) {
        // This would typically be done server-side
        // For testing, you can use Firebase Console or implement a cloud function
        print("Sending push notification to \(token): \(title) - \(body)")
        
        // Example payload for FCM
        let payload: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body
            ]
        ]
        
        // In a real app, send this to your server which then sends to FCM
        // For now, just log it
        print("FCM Payload: \(payload)")
    }
    
    func sendImmediateNotification(title: String, body: String, category: String = "GENERAL_CATEGORY") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category
        
        // Add data for handling tap
        content.userInfo = [
            "notificationType": category,
            "title": title,
            "body": body
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleNotification(identifier: String, title: String, body: String, timeInterval: TimeInterval, repeats: Bool = false, category: String = "GENERAL_CATEGORY") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category
        
        // Add data for handling tap
        content.userInfo = [
            "notificationType": category,
            "title": title,
            "body": body
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Allow notifications to show while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let title = notification.request.content.title
        let body = notification.request.content.body
        let notificationType = userInfo["notificationType"] as? String ?? "general"
        
        // Record notification received while app is active
        recordNotification(title: title, body: body, type: notificationType)
        print(" Push notification received while app is active: \(title)")
        
        completionHandler([.banner, .list, .sound])
    }
    
    // Handle notification tap when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        print(" Notification tapped: \(actionIdentifier)")
        print(" Notification data: \(userInfo)")
        
        // Extract notification data
        let title = userInfo["title"] as? String ?? ""
        let body = userInfo["body"] as? String ?? ""
        let notificationType = userInfo["notificationType"] as? String ?? "general"
        
        // Record the interaction
        recordNotification(title: title, body: body, type: "tapped_\(notificationType)")
        
        // Handle different actions
        switch actionIdentifier {
        case "VIEW_ACTION":
            // User tapped "View" - show alert in app
            showNotificationAlert(title: title, body: body, notificationType: notificationType)
        case "DISMISS_ACTION":
            // User tapped "Dismiss" - do nothing
            print("Notification dismissed")
        case "REMIND_LATER":
            // User tapped "Remind Later" - schedule reminder for later
            scheduleReminderForLater(title: title, body: body)
        case "SHARE_ACTION":
            // User tapped "Share" - handle sharing
            handleShareAction(title: title, body: body)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself - show alert
            showNotificationAlert(title: title, body: body, notificationType: notificationType)
        default:
            // Default action - show alert
            showNotificationAlert(title: title, body: body, notificationType: notificationType)
        }
        
        completionHandler()
    }
    
    private func showNotificationAlert(title: String, body: String, notificationType: String) {
        DispatchQueue.main.async {
            self.appState?.setPushNotificationAlert(title: title, message: body, notificationType: notificationType)
        }
    }
    
    private func scheduleReminderForLater(title: String, body: String) {
        // Schedule reminder for 1 hour later
        let reminderDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        scheduleReminder(title: title, body: body, date: reminderDate)
        print(" Reminder scheduled for later: \(reminderDate)")
    }
    
    private func handleShareAction(title: String, body: String) {
        // Handle sharing (placeholder)
        print(" Share action triggered for: \(title)")
        // You can implement sharing functionality here
    }
    
    func scheduleReminder(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Add data for handling tap
        content.userInfo = [
            "notificationType": "REMINDER_CATEGORY",
            "title": title,
            "body": body
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleRecurringReminder(title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Add data for handling tap
        content.userInfo = [
            "notificationType": "REMINDER_CATEGORY",
            "title": title,
            "body": body
        ]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Convenience method to send timer completion notification
    func sendTimerCompletionNotification(sessionTitle: String, duration: TimeInterval) {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let timeString = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        
        sendImmediateNotification(
            title: "Study Session Concluded",
            body: "Study activity for \(sessionTitle) recorded for a duration of \(timeString).",
            category: "TIMER_CATEGORY"
        )
    }
    
    // Convenience method to send achievement notification
    func sendAchievementNotification(achievementTitle: String) {
        sendImmediateNotification(
            title: "Requirement Fulfilled",
            body: "Academic milestone achieved: \(achievementTitle). Record updated.",
            category: "ACHIEVEMENT_CATEGORY"
        )
    }
    
    // Convenience method to send study reminder notification
    func sendStudyReminderNotification(subject: String) {
        sendImmediateNotification(
            title: "Study Reminder",
            body: "Time to study \(subject)",
            category: "REMINDER_CATEGORY"
        )
    }
}

// MARK: - Received Notification Model
struct ReceivedNotification: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let body: String
    let type: String
    let receivedAt: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: receivedAt)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: receivedAt)
    }
}
