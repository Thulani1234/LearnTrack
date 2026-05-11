//
//  ViewPlannerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ViewPlannerView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var animateItems = false

    private var weeklySessions: [StudySession] {
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        return data.scheduledSessions.filter { session in
            session.date >= weekStart && session.date <= weekEnd
        }.sorted { $0.date < $1.date }
    }

    private var sessionsByDay: [(String, [StudySession])] {
        let grouped = Dictionary(grouping: weeklySessions) { session in
            Calendar.current.component(.weekday, from: session.date)
        }
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return weekdays.enumerated().map { (index, day) in
            (day, grouped[index + 1] ?? [])
        }
    }

    private var totalWeeklyHours: Int {
        weeklySessions.reduce(0) { $0 + $1.durationSeconds } / 3600
    }

    private var focusSubjects: [String] {
        let subjectIds = Set(weeklySessions.map { $0.subjectId })
        return subjectIds.compactMap { data.subject(for: $0)?.name }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primary)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Your Study Planner")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Weekly Overview Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary)
                            Text("Weekly Overview")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }

                        HStack(spacing: 20) {
                            VStack(alignment: .center, spacing: 8) {
                                Text("\(totalWeeklyHours)")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(AppColors.primary)
                                Text("Hours")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            VStack(alignment: .center, spacing: 8) {
                                Text("\(weeklySessions.count)")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(AppColors.secondary)
                                Text("Sessions")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            VStack(alignment: .center, spacing: 8) {
                                Text("\(focusSubjects.count)")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(AppColors.accent)
                                Text("Subjects")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if !focusSubjects.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Focus Subjects")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                HStack(spacing: 12) {
                                    ForEach(focusSubjects, id: \.self) { subject in
                                        Text(subject)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppColors.primary.opacity(0.8))
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // Daily Schedule
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Daily Schedule")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        VStack(spacing: 16) {
                            ForEach(sessionsByDay.filter { !$0.1.isEmpty }, id: \.0) { day, sessions in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(day.uppercased())
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(AppColors.primary)
                                        .tracking(1)

                                    ForEach(sessions) { session in
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(data.subject(for: session.subjectId)?.name ?? "Study")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(AppColors.textPrimary)
                                                Text(session.date.formatted(.dateTime.hour().minute()))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(session.durationSeconds / 60) min")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppColors.primary)
                                                if session.isCompleted {
                                                    Text("Completed")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.green)
                                                } else {
                                                    Text("Scheduled")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(AppColors.textSecondary)
                                                }
                                            }
                                        }
                                        .padding(16)
                                        .background(AppColors.cardBackground.opacity(0.5))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Illustration Section
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary.opacity(0.3))

                        Text("Stay Consistent!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Your AI-optimized study plan is designed to maximize your learning efficiency. Stick to the schedule and track your progress regularly.")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: 300)
                    }
                    .padding(.vertical, 40)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateItems = true
            }
        }
    }
}