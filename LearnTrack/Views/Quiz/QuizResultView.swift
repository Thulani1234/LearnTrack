//
//  QuizResultView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct QuizResultView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    
    var quiz: Quiz
    var selectedAnswers: [Int?]
    
    @State private var showReview = false
    
    private var score: Int {
        zip(quiz.questions, selectedAnswers).reduce(0) { total, pair in
            let (question, selected) = pair
            return total + ((selected == question.correctIndex) ? 1 : 0)
        }
    }
    
    private var percent: Double {
        min(max(Double(score) / Double(max(quiz.questions.count, 1)), 0), 1)
    }
    
    private var quizAttempts: [Quiz] {
        data.quizzes.filter { $0.title == quiz.title }.sorted(by: { $0.dateAttempted > $1.dateAttempted })
    }
    
    private var averageQuizScore: Int {
        guard !quizAttempts.isEmpty else { return 0 }
        let total = quizAttempts.reduce(0) { $0 + $1.score }
        return total / quizAttempts.count
    }
    
    private var bestQuizScore: Int {
        quizAttempts.map { $0.score }.max() ?? 0
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz history")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quizAttempts) { attempt in
                        HistoryBadge(score: attempt.score, total: attempt.totalQuestions, date: attempt.dateAttempted)
                    }
                }
            }
            .padding(.bottom, 6)
            HStack {
                HistoryMetric(label: "Average", value: "\(averageQuizScore)/\(quiz.totalQuestions)")
                Spacer()
                HistoryMetric(label: "Best", value: "\(bestQuizScore)/\(quiz.totalQuestions)")
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 8)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Circle()
                    .fill(AppColors.secondary.opacity(0.16))
                    .frame(width: 280, height: 280)
                    .offset(x: 110, y: -160)
                Circle()
                    .fill(AppColors.primary.opacity(0.14))
                    .frame(width: 260, height: 260)
                    .offset(x: -120, y: 190)
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text("Quiz Complete")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Review your results and see which answers were correct.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(AppColors.cardBackground)
                            .frame(width: 230, height: 230)
                            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 12)
                        Circle()
                            .trim(from: 0, to: percent)
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: [AppColors.primary, AppColors.secondary, AppColors.accent]), center: .center),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 230, height: 230)
                        VStack(spacing: 8) {
                            Text("\(Int(percent * 100))%")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(score) / \(quiz.questions.count)")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        ScoreLine(label: "Correct", value: score, color: AppColors.success)
                        ScoreLine(label: "Incorrect", value: quiz.questions.count - score, color: AppColors.error)
                    }
                    .padding(.horizontal, 24)
                    
                    historySection
                    
                    VStack(spacing: 14) {
                        PrimaryButton(title: "Back to Quizzes") {
                            dismiss()
                            router.navigateBack()
                        }
                        Button(action: {
                            showReview = true
                        }) {
                            Text("Review answers")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(isPresented: $showReview) {
            QuizReviewView(quiz: quiz, selectedAnswers: selectedAnswers)
        }
    }
}

private struct ScoreLine: View {
    var label: String
    var value: Int
    var color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("\(value)")
                .font(AppTypography.headline)
                .foregroundColor(color)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

private struct HistoryBadge: View {
    var score: Int
    var total: Int
    var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(score)/\(total)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(date, format: .dateTime.month().day())
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(18)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

private struct HistoryMetric: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(14)
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
}
