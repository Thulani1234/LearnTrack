//
//  QuizListView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct QuizListView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    
    private var quizzes: [Quiz] { data.quizzes }
    private var latestQuiz: String {
        quizzes.sorted(by: { $0.dateAttempted > $1.dateAttempted }).first?.title ?? "Practice"
    }
    private var averageScore: Int {
        guard !quizzes.isEmpty else { return 0 }
        let total = quizzes.reduce(0) { partial, quiz in
            partial + Int((Double(quiz.score) / Double(max(quiz.totalQuestions, 1))) * 100)
        }
        return total / quizzes.count
    }
    private var bestScore: String {
        guard let maxScore = quizzes.map({ $0.score }).max() else { return "0/0" }
        return "\(maxScore)/\(quizzes.first?.totalQuestions ?? 0)"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                QuizListHeader(completed: quizzes.count, bestScore: bestScore, nextQuiz: latestQuiz, averageScore: averageScore)
                    .padding(.horizontal)
                    .padding(.top)
                historySection
                VStack(spacing: 16) {
                    ForEach(quizzes) { quiz in
                        QuizCard(quiz: quiz)
                            .onTapGesture {
                                router.navigate(to: .quiz(quiz))
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Quizzes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Score history")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quizzes.sorted(by: { $0.dateAttempted > $1.dateAttempted })) { quiz in
                        QuizHistoryPill(quiz: quiz)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct QuizListHeader: View {
    var completed: Int
    var bestScore: String
    var nextQuiz: String
    var averageScore: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Library")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            Text("Stay sharp with quick practice rounds and track your performance.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            HStack(spacing: 12) {
                ScoreBadge(label: "Completed", value: "\(completed)")
                ScoreBadge(label: "Best score", value: bestScore)
                ScoreBadge(label: "Average", value: "\(averageScore)%")
            }
            Text("Latest attempt: \(nextQuiz)")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
    }
}

private struct QuizHistoryPill: View {
    var quiz: Quiz
    
    private var progressColor: Color {
        switch quiz.score {
        case 0..<2: return AppColors.error
        case 2..<3: return AppColors.secondary
        default: return AppColors.success
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(quiz.title)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
            Text("\(quiz.score)/\(quiz.totalQuestions)")
                .font(AppTypography.headline)
                .foregroundColor(progressColor)
            Text(quiz.dateAttempted, format: .dateTime.month().day())
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

private struct ScoreBadge: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

struct QuizCard: View {
    var quiz: Quiz
    
    private var accent: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var scoreText: String {
        "\\(quiz.score)/\\(quiz.totalQuestions)"
    }
    
    private var dateText: String {
        quiz.dateAttempted.formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(accent)
                .shadow(color: AppColors.primary.opacity(0.18), radius: 20, x: 0, y: 10)
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(quiz.title)
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                        Text(dateText)
                            .font(AppTypography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text(scoreText)
                        .font(AppTypography.title)
                        .foregroundColor(.white)
                }
                HStack {
                    Label("Practice", systemImage: "bolt.fill")
                        .font(AppTypography.caption)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    Spacer()
                    Text("Quick review")
                        .font(AppTypography.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(22)
        }
        .frame(height: 150)
    }
}

