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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Study Planner")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Stay organized and hit your goals.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Button(action: { router.navigate(to: .planSession) }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "plus")
                                .foregroundColor(AppColors.primary)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Smart Plan Card
                Button(action: { router.navigate(to: .planSetup) }) {
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 60, height: 60)
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI Study Plan")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Generate your weekly schedule")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(24)
                    .background(LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(32)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                }
                .padding(.horizontal)
                
                // Calendar Strip
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT DATE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<14) { i in
                                let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                DayItem(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedDate = date
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Sessions List
                VStack(alignment: .leading, spacing: 20) {
                    Text("SESSIONS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    ScheduledSessionsView(date: selectedDate)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct DayItem: View {
    var date: Date
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 60, height: 90)
        .background(isSelected ? AppColors.primary : AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}


