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
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Push notification permission granted.")
            } else if let error = error {
                print("Error requesting push notification authorization: \(error.localizedDescription)")
            }
        }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Set up Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        // Initialize other services
        NotificationManager.shared.requestPermission()
        
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
        print("Received remote notification: \(userInfo)")
        completionHandler(.newData)
    }
    
    // Firebase Messaging delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
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
        print("User interacted with notification: \(response.notification.request.identifier)")
        completionHandler()
    }
}

@main
struct LearnTrackApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(MockData.shared)
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
                .preferredColorScheme(.light)
        }
    }
}
