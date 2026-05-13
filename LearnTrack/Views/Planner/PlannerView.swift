//
//  PlannerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @StateObject private var calendarViewModel = FullCalendarViewModel()
    @State private var animatePulse = false
    
    private var scheduleDateRange: [Date] {
        (-2...2).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.selectedDate)
        }
    }
    
    private func sessionsForDate(_ date: Date) -> [StudySession] {
        data.scheduledSessions
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    private var sessionsForSelectedDate: [StudySession] {
        sessionsForDate(calendarViewModel.selectedDate)
    }
    
    private func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func subjectAccentColor(for subjectId: UUID) -> Color {
        let subjectName = data.subject(for: subjectId)?.name.lowercased() ?? ""
        if subjectName.contains("math") { return AppColors.primary }
        if subjectName.contains("science") { return AppColors.secondary }
        if subjectName.contains("english") { return AppColors.accent }
        if subjectName.contains("music") { return AppColors.success }
        if subjectName.contains("physics") { return AppColors.warning }
        if subjectName.contains("chemistry") { return Color(hex: "8B5CF6") }
        return AppColors.primary
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Creative Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .tracking(1)
                        
                        Text("Study Planner")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    
                    Button(action: { router.navigate(to: .planSession) }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 48, height: 48)
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Immersive AI Plan Card
                Button(action: { router.navigate(to: .planSetup) }) {
                    ZStack(alignment: .leading) {
                        // Background Mesh Gradient
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary, Color(hex: "818CF8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Abstract Glowing Shapes
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 150, height: 150)
                            .blur(radius: 40)
                            .offset(x: 200, y: -40)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Personalized Study Planner")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(.white)
                                Text("OPTIMIZED FOR YOU")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weekly Focus: Bright Momentum")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Your plan is tuned for steady progress: energize your next session with clarity and calm.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            .padding(.top, 10)
                            
                            HStack {
                                Text("Generate New Plan")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 12)
                        }
                        .padding(28)
                    }
                    .frame(height: 240)
                    .cornerRadius(32)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 20, x: 0, y: 12)
                }
                .padding(.horizontal)
                .onAppear { animatePulse = true }
                
                // Schedule Strip
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Schedule")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(AppColors.textSecondary.opacity(0.5))
                                .tracking(2)
                            Text(calendarViewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                        Button(action: {
                            router.navigate(to: .viewPlanner)
                        }) {
                            Text("View Planner")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.primary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(AppColors.primary.opacity(0.12))
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(scheduleDateRange, id: \.self) { date in
                                DayItem(
                                    date: date,
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate),
                                    hasSession: !sessionsForDate(date).isEmpty
                                )
                                .onTapGesture {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        calendarViewModel.selectedDate = date
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                
                // Sessions List
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: calendarViewModel.selectedDate) - 1].uppercased()) · \(dateLabel(for: calendarViewModel.selectedDate))")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(AppColors.primary)
                                .tracking(1)
                            Text("Study sessions for the selected date")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    if sessionsForSelectedDate.isEmpty {
                        Text("No sessions scheduled for this date.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(sessionsForSelectedDate) { session in
                            HStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(subjectAccentColor(for: session.subjectId).opacity(0.2))
                                    .frame(width: 6)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(data.subject(for: session.subjectId)?.name ?? "Study")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("\(session.date.formatted(.dateTime.hour().minute())) · \(session.durationSeconds / 60) min")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                    Text(session.isCompleted ? "Review" : "Study")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(session.isCompleted ? AppColors.warning : .white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 18)
                                        .background(session.isCompleted ? AppColors.cardBackground : AppColors.primary)
                                        .cornerRadius(20)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            animatePulse = true
            calendarViewModel.plannerSessions = data.scheduledSessions
        }
    }
}

struct DayItem: View {
    var date: Date
    var isSelected: Bool
    var hasSession: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            
            if hasSession {
                Circle()
                    .fill(isSelected ? Color.white : AppColors.primary)
                    .frame(width: 6, height: 6)
                    .opacity(isSelected ? 1 : 0.9)
                    .offset(y: 10)
            }
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


