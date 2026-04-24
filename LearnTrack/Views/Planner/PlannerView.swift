//
//  PlannerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Weekly Planner")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: { router.navigate(to: .planSession) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Button(action: { router.navigate(to: .planSetup) }) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Create Study Plan")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Generate a personalized study schedule")
                            .font(AppTypography.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(20)
            }
            .padding(.horizontal)
            
            // Week Calendar (simplified)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<7) { i in
                        let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                        DayView(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            // Sessions for selected day
            ScheduledSessionsView(date: selectedDate)
            
            Spacer()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Planner")
        .navigationBarHidden(true)
    }
}

struct DayView: View {
    var date: Date
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(AppTypography.caption)
                .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(AppTypography.headline)
                .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isSelected ? AppColors.primary : AppColors.cardBackground)
        .cornerRadius(12)
    }
}

