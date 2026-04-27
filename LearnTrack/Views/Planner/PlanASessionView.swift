//
//  PlanASessionView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//


import SwiftUI

struct PlanASessionView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedSubjectIndex = 0
    @State private var duration = 30
    @State private var sessionDate = Date()
    @State private var scheduledSession: StudySession? = nil
    
    let subjects = MockData.shared.subjects
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppColors.textPrimary)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    Text("Plan a Session")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Schedule a subject, set the time, and save the session to your planner.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 18) {
                    SectionCard(title: "Subject") {
                        Picker("Select Subject", selection: $selectedSubjectIndex) {
                            ForEach(0..<subjects.count, id: \.self) { index in
                                Text(subjects[index].name).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    SectionCard(title: "Duration & Time") {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Text("Duration")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Button(action: {
                                    if duration > 15 {
                                        duration -= 15
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(duration > 15 ? .white : AppColors.textSecondary)
                                        .background(duration > 15 ? AppColors.primary : AppColors.cardElevated)
                                        .clipShape(Circle())
                                }
                                .disabled(duration <= 15)
                                
                                Text("\(duration) mins")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(minWidth: 80)
                                
                                Button(action: {
                                    if duration < 180 {
                                        duration += 15
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(duration < 180 ? .white : AppColors.textSecondary)
                                        .background(duration < 180 ? AppColors.primary : AppColors.cardElevated)
                                        .clipShape(Circle())
                                }
                                .disabled(duration >= 180)
                            }
                            DatePicker("Start Time", selection: $sessionDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                    }
                }
                .padding(.horizontal)
                
                PrimaryButton(title: "Schedule Session") {
                    scheduledSession = StudySession(
                        subjectId: subjects[selectedSubjectIndex].id,
                        date: sessionDate,
                        durationSeconds: duration * 60,
                        isCompleted: false,
                        summary: nil
                    )
                    NotificationManager.shared.scheduleReminder(
                        title: "Study Time: \\(subjects[selectedSubjectIndex].name)",
                        body: "Your planned session is starting soon.",
                        date: sessionDate
                    )
                }
                .padding(.horizontal)
                
                if let scheduled = scheduledSession,
                   let subject = subjects.first(where: { $0.id == scheduled.subjectId }) {
                    SessionConfirmationCard(session: scheduled, subject: subject)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

private struct SectionCard<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            content
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(18)
        }
    }
}

private struct SessionConfirmationCard: View {
    var session: StudySession
    var subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Session Scheduled")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Your session is now added to the planner.")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppColors.success)
                    .font(.title)
            }
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("\(session.durationSeconds / 60) min")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.primary.opacity(0.12))
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}
