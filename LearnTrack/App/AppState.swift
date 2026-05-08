//
//  AppState.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool = true
    @Published var isLocked: Bool = true
    @Published var selectedTab: Int = 0
    @Published var isLoggedIn: Bool = false
    @Published var currentAlert: AppAlert? = nil
    @Published var pushNotificationAlert: AppAlert? = nil
    @Published var isJoiningRoom: Bool = false
    @Published var joiningRoomName: String = ""
    @Published var currentUser: User? = nil {
        didSet {
            if let currentUser {
                MockData.shared.configure(for: currentUser)
            } else {
                MockData.shared.resetForSignedOutUser()
            }
        }
    }
    @Published var isDarkModeEnabled: Bool = false
    @Published var isDynamicTypeEnabled: Bool = false
    @Published var pendingNotification: (title: String, body: String, type: String)? = nil
    
    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstLaunch") == nil {
            isFirstLaunch = true
        } else {
            isFirstLaunch = defaults.bool(forKey: "isFirstLaunch")
        }
    }
    
    func completeOnboarding() {
        isFirstLaunch = false
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
    }
    
    func unlock() {
        isLocked = false
    }
    
    func lock() {
        isLocked = true
    }
    
    func setPushNotificationAlert(title: String, message: String, notificationType: String = "general") {
        pushNotificationAlert = AppAlert(
            title: title,
            message: message,
            icon: iconForNotificationType(notificationType),
            color: colorForNotificationType(notificationType),
            type: .notification
        )
    }
    
    private func iconForNotificationType(_ type: String) -> String {
        switch type.lowercased() {
        case "timer", "session": return "timer.circle.fill"
        case "achievement": return "star.fill"
        case "reminder": return "bell.fill"
        case "warning": return "exclamationmark.circle.fill"
        case "success": return "checkmark.circle.fill"
        default: return "bell.badge.fill"
        }
    }
    
    private func colorForNotificationType(_ type: String) -> Color {
        switch type.lowercased() {
        case "timer", "session": return .blue
        case "achievement": return .yellow
        case "reminder": return .orange
        case "warning": return .red
        case "success": return .green
        default: return .blue
        }
    }
}
struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let color: Color
    var type: AppAlertType = .info
}

enum AppAlertType {
    case info, warning, success, notification
}
