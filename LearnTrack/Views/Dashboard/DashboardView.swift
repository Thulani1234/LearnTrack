//
//  DashboardView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData

    private var userDisplayName: String {
        let name = appState.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "User" : name
    }

    private var userInitial: String {
        String(userDisplayName.prefix(1)).uppercased()
    }
    
    private var todayStudySeconds: Int {
        let calendar = Calendar.current
        return data.recentSessions
            .filter { $0.isCompleted && calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.durationSeconds }
    }
    
    private var dailyGoalSeconds: Int {
        5 * 60 * 60 // default 5-hour daily study goal
    }
    
    private var dailyProgress: Double {
        guard dailyGoalSeconds > 0 else { return 0 }
        return min(1, Double(todayStudySeconds) / Double(dailyGoalSeconds))
    }
    
    private var dailyProgressText: String {
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
    
    private var autoPlanItems: [Subject] {
        if data.subjects.isEmpty {
            return []
        }
        return Array(data.subjects.sorted { $0.progress < $1.progress }.prefix(3))
    }
    
    private var hasDashboardData: Bool {
        !data.subjects.isEmpty || !data.recentSessions.isEmpty || !data.academicResults.isEmpty
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Date().formatted(.dateTime.weekday().month().day()))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Welcome,")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("\(userDisplayName) 👋")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Text("🔥")
                            Text("7")
                                .font(AppTypography.headline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(20)
                        
                        Button(action: {
                            router.navigate(to: .notifications)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.cardBackground)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppColors.textPrimary)
                                    .overlay(
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: 8, y: -8)
                                    )
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                appState.selectedTab = 5 // Navigate to Profile tab
                            }
                        }) {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 44, height: 44)
                                .overlay(Text(userInitial).foregroundColor(.white).fontWeight(.bold))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Daily Study Goal
                DailyStudyGoalSection(
                    userName: userDisplayName,
                    progress: dailyProgress,
                    progressLabel: dailyProgressText,
                    completedSeconds: todayStudySeconds,
                    goalSeconds: dailyGoalSeconds,
                    hasData: hasDashboardData
                )
                
                // Today's Auto Plan
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("TODAY'S AUTO PLAN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        Spacer()
                        Text("Auto-generated")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.1))
                            .foregroundColor(AppColors.primary)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    if autoPlanItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No auto plan available yet")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Text("Add a subject and some study time to generate a personalized plan for today.")
                                .font(AppTypography.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(autoPlanItems.enumerated()), id: \ .element.id) { index, subject in
                                AutoPlanItem(
                                    icon: subject.icon,
                                    title: "\(subject.name) — \((index + 1) * 30) min",
                                    status: index == 0 ? "Urgent" : (index == 1 ? "Soon" : "Planned"),
                                    isCompleted: false
                                )
                                if index < autoPlanItems.count - 1 {
                                    Divider().padding(.leading, 60)
                                }
                            }
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 5)
                    }
                }
                
                // Live Session Card
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .padding(4)
                        .background(Color.green.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.joiningRoomName.isEmpty ? "Live Study Rooms" : "Live Session Active")
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                        Text(appState.joiningRoomName.isEmpty ? "Start or join a live focus room from the Live tab." : "3 students studying Science now")
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(appState.joiningRoomName.isEmpty ? "Open Live" : "Join") {
                        if appState.joiningRoomName.isEmpty {
                            withAnimation {
                                appState.selectedTab = 2
                            }
                        } else {
                            withAnimation {
                                appState.isJoiningRoom = true
                            }
                        }
                    }
                    .font(AppTypography.bodySmall)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(20)
                .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(24)
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            SquareActionCard(title: "Timer", icon: "timer", color: .purple) {
                                if let subject = data.subjects.first {
                                    router.navigate(to: .timer(subject))
                                } else {
                                    appState.currentAlert = AppAlert(
                                        title: "Add a Subject First",
                                        message: "Create a subject before starting a focus timer.",
                                        icon: "books.vertical.fill",
                                        color: AppColors.primary,
                                        type: .info
                                    )
                                    appState.selectedTab = 3
                                }
                            }
                            SquareActionCard(title: "Notes", icon: "book.closed.fill", color: .green) {
                                router.navigate(to: .notes)
                            }
                            SquareActionCard(title: "Voice", icon: "mic.fill", color: .orange) {
                                router.navigate(to: .voiceNotes)
                            }
                            SquareActionCard(title: "Report", icon: "chart.bar.fill", color: .yellow) {
                                withAnimation {
                                    appState.selectedTab = 4 // Navigate to Report tab
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            
            // Check for pending notifications when navigating to home page
            if let title = UserDefaults.standard.string(forKey: "pendingNotificationTitle"),
               let body = UserDefaults.standard.string(forKey: "pendingNotificationBody"),
               let type = UserDefaults.standard.string(forKey: "pendingNotificationType") {
                
                print("✅ Dashboard: Found pending notification: \(title)")
                
                // Display immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
    }
}

struct DailyStudyGoalSection: View {
    @EnvironmentObject var router: AppRouter
    var userName: String
    var progress: Double
    var progressLabel: String
    var completedSeconds: Int
    var goalSeconds: Int
    var hasData: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY STUDY GOAL")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                .padding(.horizontal)

            if hasData {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(AppColors.primary.opacity(0.1), lineWidth: 12)
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 0) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("done")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Almost there, \(userName)!")
                            .font(.system(size: 18, weight: .bold))
                        Text(progressLabel)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
                .background(AppColors.cardBackground)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to your dashboard")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Add your first subject, log a study session, or enter a result to see your progress summary here.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        router.navigate(to: .addSubject)
                    }) {
                        Text("Add your first subject")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.primary)
                            .cornerRadius(16)
                    }
                }
                .padding(24)
                .background(AppColors.cardBackground)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            }
        }
    }
}

struct AutoPlanItem: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    var icon: String
    var title: String
    var status: String
    var isCompleted: Bool
    
    var body: some View {
        Button(action: {
            if let subjectName = title.components(separatedBy: " — ").first,
               let subject = data.subjects.first(where: { $0.name == subjectName }) {
                router.navigate(to: .timer(subject))
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.background)
                    .cornerRadius(14)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(status)
                        .font(.system(size: 12))
                        .foregroundColor(status == "Urgent" ? .red : (status == "Soon" ? .orange : .blue))
                }
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? Color.green : AppColors.textSecondary.opacity(0.3))
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SquareActionCard: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 90)
            .background(color)
            .cornerRadius(20)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct SessionCard: View {
    var session: StudySession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Subject Session") // In real app, fetch subject name by ID
                    .font(AppTypography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(timeString(session.durationSeconds))")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .foregroundColor(AppColors.primary)
                .font(.title)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // Convert seconds → hh:mm:ss
    func timeString(_ time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
