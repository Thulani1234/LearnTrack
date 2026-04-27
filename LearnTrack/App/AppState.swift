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
    case info, warning, success
}
