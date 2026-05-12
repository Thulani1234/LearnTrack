//
//  DashboardViewModel.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-05-12.
//

import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var appState: AppState
    @Published var router: AppRouter
    @Published var data: MockData

    init(appState: AppState, router: AppRouter, data: MockData) {
        self.appState = appState
        self.router = router
        self.data = data
    }

    var userDisplayName: String {
        let name = appState.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "User" : name
    }

    var userInitial: String {
        String(userDisplayName.prefix(1)).uppercased()
    }

    var todayStudySeconds: Int {
        let calendar = Calendar.current
        return data.recentSessions
            .filter { $0.isCompleted && calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.durationSeconds }
    }

    var dailyGoalSeconds: Int {
        5 * 60 * 60 // default 5-hour daily study goal
    }

    var dailyProgress: Double {
        guard dailyGoalSeconds > 0 else { return 0 }
        return min(1, Double(todayStudySeconds) / Double(dailyGoalSeconds))
    }

    var dailyProgressText: String {
        let hours = todayStudySeconds / 3600
        let minutes = (todayStudySeconds % 3600) / 60
        if todayStudySeconds == 0 {
            return "Start studying to track your daily progress."
        }
        if hours > 0 {
            return "You've completed \(hours)h \(minutes)m of study today."
        }
        return "You've completed \(minutes)m of study today."
    }

    var autoPlanItems: [Subject] {
        if data.subjects.isEmpty {
            return []
        }
        return Array(data.subjects.sorted { $0.progress < $1.progress }.prefix(3))
    }

    var hasDashboardData: Bool {
        !data.subjects.isEmpty || !data.recentSessions.isEmpty || !data.academicResults.isEmpty
    }

    // Dynamic greeting based on time
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Welcome"
        }
    }

    func navigateToNotifications() {
        router.navigate(to: .notifications)
    }

    func navigateToProfile() {
        appState.selectedTab = 5 // Navigate to Profile tab
    }
}