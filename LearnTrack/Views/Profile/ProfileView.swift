//
//  ProfileView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 40)
                
                VStack(spacing: 4) {
                    Text("Alex Johnson")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Grade 11 Student")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack(spacing: 20) {
                    AchievementBadge(icon: "flame.fill", value: "7 Days", title: "Streak", color: AppColors.warning)
                    AchievementBadge(icon: "star.fill", value: "12", title: "Quizzes", color: AppColors.accent)
                    AchievementBadge(icon: "clock.fill", value: "45h", title: "Studied", color: AppColors.secondary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    NavigationLink(destination: SettingsView()) {
                        ProfileOptionRow(icon: "gearshape.fill", title: "Settings")
                    }
                    ProfileOptionRow(icon: "bell.fill", title: "Notifications")
                    ProfileOptionRow(icon: "lock.fill", title: "Privacy")
                    ProfileOptionRow(icon: "questionmark.circle.fill", title: "Help & Support")
                }
                .padding(.horizontal)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarHidden(true)
    }
}

struct AchievementBadge: View {
    var icon: String
    var value: String
    var title: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct ProfileOptionRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            Text(title)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textSecondary)
                .font(.caption)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
