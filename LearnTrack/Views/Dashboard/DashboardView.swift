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
                DailyStudyGoalSection(userName: userDisplayName)
                
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
                    
                    VStack(spacing: 0) {
                        AutoPlanItem(icon: "microscope", title: "Science — 60 min", status: "Urgent", isCompleted: false)
                        Divider().padding(.leading, 60)
                        AutoPlanItem(icon: "plus", title: "Maths — 45 min", status: "Soon", isCompleted: false)
                        Divider().padding(.leading, 60)
                        AutoPlanItem(icon: "laptopcomputer", title: "ICT — 30 min", status: "Planned", isCompleted: true)
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 5)
                }
                
                // Live Session Card
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .padding(4)
                        .background(Color.green.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Live Session Active")
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                        Text("3 students studying Science now")
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Button("Join") {
                        withAnimation {
                            appState.joiningRoomName = "Science Study Group"
                            appState.isJoiningRoom = true
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
    }
}

struct DailyStudyGoalSection: View {
    var userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY STUDY GOAL")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(AppColors.primary.opacity(0.1), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: 0.65)
                        .stroke(
                            LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("65%")
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
                    Text("You've completed 4.5 hours of study today. Just 1.5 more to reach your goal.")
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
