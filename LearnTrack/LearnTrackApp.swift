//
//  LearnTrackApp.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

/*
import SwiftUI

@main
struct LearnTrackApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(MockData.shared)
                .preferredColorScheme(.light) // Dark mode focus
        }
    }
}
*/
import SwiftUI
import FirebaseCore

@main
struct LearnTrackApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.requestPermission()
        
        // Initialize Core Data and perform migration if needed
        DataMigrationService.shared.performInitialMigrationIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(MockData.shared)
                .preferredColorScheme(.light)
        }
    }
}
