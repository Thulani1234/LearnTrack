//
//  DashboardView..swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var router: AppRouter
    let subjects = MockData.shared.subjects
    let scheduledSessions = MockData.shared.scheduledSessions
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Good Morning,")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Alex 👋")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    Button(action: {
                        router.navigate(to: .notifications)
                    }) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(AppColors.primary)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Progress Tracker Summary
                ProgressTrackerView(subjects: subjects)
                    .padding(.horizontal)
                
                // Today's Plan
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Today's Plan")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Button("See All") {
                            router.navigate(to: .planner)
                        }
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.primary)
                    }
                    .padding(.horizontal)
                    
                    if scheduledSessions.isEmpty {
                        Text("No sessions scheduled for today.")
                            .font(AppTypography.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(scheduledSessions.prefix(2)) { session in
                            SessionCard(session: session)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        QuickActionCard(title: "Start Timer", icon: "timer", color: AppColors.primary) {
                            router.navigate(to: .timer(subjects.first!))
                        }
                        QuickActionCard(title: "Take Quiz", icon: "checkmark.seal.fill", color: AppColors.accent) {
                            router.navigate(to: .quizList)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        QuickActionCard(title: "Voice Notes", icon: "mic.fill", color: AppColors.secondary) {
                            router.navigate(to: .voiceNotes)
                        }
                        QuickActionCard(title: "Log Result", icon: "rosette", color: AppColors.warning) {
                            router.navigate(to: .results)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Dashboard")
        .navigationBarHidden(true)
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
                Text("\(timeString(session.durationMinutes * 60))")
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

struct QuickActionCard: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(AppTypography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
}

