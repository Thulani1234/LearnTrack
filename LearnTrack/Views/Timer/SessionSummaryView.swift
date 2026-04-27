//
//  SessionSummaryView..swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//
import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.presentationMode) var presentationMode
    
    var subject: Subject
    var duration: Int
    var quizScore: Int? = nil
    var progressGain: Int? = nil
    
    @State private var notesText = ""
    @State private var showAddNoteSheet = false
    @State private var newNoteText = ""
    
    private var summaryText: String {
        if !notesText.isEmpty {
            return notesText
        }
        return "You studied \(subject.name) for \(timeString(duration)) — covering core concepts, reviewing examples, and strengthening your recall. Keep the momentum going with one more review before your next test."
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 260)
                Spacer()
            }
            VStack(spacing: 20) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back to Timer")
                                .font(AppTypography.bodySmall)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Complete!")
                        .font(AppTypography.title)
                        .foregroundColor(.white)
                    Text("Here’s your study summary")
                        .font(AppTypography.body)
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal)
                
                HStack(spacing: 14) {
                    SummaryMetric(title: "Time", value: timeString(duration), subtitle: "Study time", color: Color.white.opacity(0.2))
                    SummaryMetric(title: "Score", value: quizScore != nil ? "\(quizScore!)/10" : "8/10", subtitle: "Quiz score", color: Color.white.opacity(0.2))
                    SummaryMetric(title: "Gain", value: progressGain != nil ? "+\(progressGain!)%" : "+10%", subtitle: "Progress", color: Color.white.opacity(0.2))
                }
                .padding(.horizontal)
                
                VStack(spacing: 18) {
                    SessionOverviewCard(subject: subject, duration: timeString(duration))
                    AISummaryCard(text: summaryText)
                    WeeklyProgressCard()
                }
                .padding(.horizontal)
                
                HStack(spacing: 14) {
                    ActionButton(icon: "mic.fill", title: "Voice Note", color: AppColors.cardBackground) {
                        presentationMode.wrappedValue.dismiss()
                        router.navigate(to: .voiceNotes)
                    }
                    ActionButton(icon: "checkmark.seal.fill", title: "Take Quiz", color: AppColors.cardBackground) {
                        presentationMode.wrappedValue.dismiss()
                        router.navigate(to: .quizList)
                    }
                    ActionButton(icon: "note.text", title: "Add Note", color: AppColors.cardBackground) {
                        showAddNoteSheet = true
                    }
                }
                .padding(.horizontal)
                
                PrimaryButton(title: "Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showAddNoteSheet) {
            NavigationStack {
                VStack(spacing: 18) {
                    Text("Add Session Note")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 20)
                    TextEditor(text: $newNoteText)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(16)
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .frame(height: 220)
                    Spacer()
                    PrimaryButton(title: "Save Note") {
                        notesText = newNoteText
                        showAddNoteSheet = false
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .background(AppColors.background.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddNoteSheet = false
                        }
                    }
                }
            }
        }
    }
    
    // Convert seconds → hh:mm:ss
    func timeString(_ time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

private struct SummaryMetric: View {
    var title: String
    var value: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppTypography.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(20)
    }
}

private struct SessionOverviewCard: View {
    var subject: Subject
    var duration: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.primary.opacity(0.16))
                    .cornerRadius(14)
                VStack(alignment: .leading, spacing: 6) {
                    Text(subject.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Today · 2:30 PM - 3:15 PM")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("Exam in 2 days")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.error)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.error.opacity(0.12))
                    .cornerRadius(16)
            }
            Divider()
            HStack {
                Text("\(duration) session")
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("Focused review")
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 5)
    }
}

private struct AISummaryCard: View {
    var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("✨ AI SESSION SUMMARY")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.primary)
                .textCase(.uppercase)
            Text(text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.primary.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct WeeklyProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progress This Week")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            SessionProgressRow(label: "Study time", value: "3h 45m", percent: 0.75, color: AppColors.primary)
            SessionProgressRow(label: "Quiz avg", value: "80%", percent: 0.8, color: AppColors.accent)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
    }
}

private struct SessionProgressRow: View {
    var label: String
    var value: String
    var percent: Double
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(value)
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textPrimary)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.cardBackground)
                    .frame(height: 10)
                Capsule()
                    .fill(color)
                    .frame(width: CGFloat(percent) * 180, height: 10)
            }
        }
    }
}

private struct ActionButton: View {
    var icon: String
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppColors.textPrimary)
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(20)
        }
    }
}
