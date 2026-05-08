//
//  LearnTrackApp.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseMessaging
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up push notifications
        Messaging.messaging().delegate = self
        
        // Initialize NotificationManager early so notification delegate and categories are ready
        NotificationManager.shared.initialize()
        NotificationManager.shared.requestPermission()
        
        // Fetch current FCM token and save it if we already know the current user
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error retrieving FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("🔑 Current Firebase registration token: \(token)")
                if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
                    FirestoreManager.shared.saveFCMToken(userId: userId, token: token)
                }
            }
        }
        
        // Initialize Core Data and perform migration if needed
        DataMigrationService.shared.performInitialMigrationIfNeeded()
        
        return true
    }
    
    // Handle device token for push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Device token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // Handle incoming push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📲 Received server push notification: \(userInfo)")
        
        // Extract notification data from FCM payload
        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                let title = alert["title"] as? String ?? "LearnTrack"
                let body = alert["body"] as? String ?? ""
                let notificationType = userInfo["notificationType"] as? String ?? "general"
                
                // Store as pending notification for display when app opens
                UserDefaults.standard.set(title, forKey: "pendingNotificationTitle")
                UserDefaults.standard.set(body, forKey: "pendingNotificationBody")
                UserDefaults.standard.set(notificationType, forKey: "pendingNotificationType")
                UserDefaults.standard.set(Date(), forKey: "pendingNotificationDate")
                
                // Display as local notification
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                
                // Add custom data
                if let notificationType = userInfo["notificationType"] as? String {
                    content.userInfo["notificationType"] = notificationType
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error displaying push notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Push notification displayed to user")
                    }
                }
            }
        }
        
        completionHandler(.newData)
    }
    
    // Firebase Messaging delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔑 Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // Save token to Firestore if user is logged in
        if let token = fcmToken, let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            FirestoreManager.shared.saveFCMToken(userId: userId, token: token)
        }
    }
    
    // UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 User tapped push notification: \(response.notification.request.identifier)")
        
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        let title = notification.request.content.title
        let body = notification.request.content.body
        let notificationType = userInfo["notificationType"] as? String ?? "general"
        
        // Post notification to app to display alert
        NotificationCenter.default.post(
            name: NSNotification.Name("PushNotificationReceived"),
            object: nil,
            userInfo: [
                "title": title,
                "body": body,
                "notificationType": notificationType
            ]
        )
        
        completionHandler()
    }
}

@main
struct LearnTrackApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appState: AppState
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        NotificationManager.shared.setAppState(appState)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(MockData.shared)
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
                .preferredColorScheme(appState.isDarkModeEnabled ? .dark : .light)
                .applyDynamicType(appState.isDynamicTypeEnabled)
                .onAppear {
                    // Initialize NotificationManager with AppState
                    NotificationManager.shared.initialize()
                    
                    // Check for pending notifications from UserDefaults
                    if let title = UserDefaults.standard.string(forKey: "pendingNotificationTitle"),
                       let body = UserDefaults.standard.string(forKey: "pendingNotificationBody"),
                       let type = UserDefaults.standard.string(forKey: "pendingNotificationType") {
                        
                        print("✅ Found pending notification: \(title)")
                        
                        // Display immediately
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            appState.setPushNotificationAlert(
                                title: title,
                                message: body,
                                notificationType: type
                            )
                            
                            // Clear pending notification after displaying
                            UserDefaults.standard.removeObject(forKey: "pendingNotificationTitle")
                            UserDefaults.standard.removeObject(forKey: "pendingNotificationBody")
                            UserDefaults.standard.removeObject(forKey: "pendingNotificationType")
                            UserDefaults.standard.removeObject(forKey: "pendingNotificationDate")
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PushNotificationReceived"))) { notification in
                    if let userInfo = notification.userInfo as? [String: Any] {
                        let title = userInfo["title"] as? String ?? "Notification"
                        let body = userInfo["body"] as? String ?? ""
                        let notificationType = userInfo["notificationType"] as? String ?? "general"
                        
                        appState.setPushNotificationAlert(
                            title: title,
                            message: body,
                            notificationType: notificationType
                        )
                    }
                }
        }
    }
}
