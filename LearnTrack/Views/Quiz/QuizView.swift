//
//  QuizView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct QuizView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    var quiz: Quiz
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var selectedAnswers: [Int?]
    @State private var hasSubmitted = false
    
    private var quizHistory: [Quiz] {
        data.quizzes.filter { $0.title == quiz.title }.sorted(by: { $0.dateAttempted > $1.dateAttempted })
    }
    
    private var bestHistoryScore: Int {
        quizHistory.map { $0.score }.max() ?? 0
    }
    
    init(quiz: Quiz) {
        self.quiz = quiz
        self._selectedAnswers = State(initialValue: Array(repeating: nil, count: quiz.questions.count))
    }
    
    var currentQuestion: QuizQuestion {
        quiz.questions[currentQuestionIndex]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quiz Challenge")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Answer each question, then review correct and incorrect responses.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Best score")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(bestHistoryScore)/\(quiz.totalQuestions)")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primary)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Attempts")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(quizHistory.count)")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.accent)
                        }
                    }
                    .padding(16)
                    .background(AppColors.cardBackground)
                    .cornerRadius(22)
                }
                .padding(.horizontal)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.secondary.opacity(0.2), AppColors.background]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 30, x: 0, y: 10)
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Question \(currentQuestionIndex + 1)")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                Text(currentQuestion.question)
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Spacer()
                            Text("\(currentQuestionIndex + 1)/\(quiz.questions.count)")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.primary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(AppColors.primary.opacity(0.16))
                                .cornerRadius(16)
                        }
                        .padding(.top, 18)
                        ProgressBar(progress: Double(currentQuestionIndex + 1) / Double(max(quiz.questions.count, 1)), color: AppColors.secondary)
                            .frame(height: 10)
                    }
                    .padding(24)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(currentQuestion.options.indices, id: \.self) { index in
                        let answerText = currentQuestion.options[index]
                        Button(action: {
                            selectedAnswer = index
                            selectedAnswers[currentQuestionIndex] = index
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(answerText)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(selectedAnswer == index ? "Selected" : "Tap to choose")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                                if selectedAnswer == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.secondary)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedAnswer == index ? AppColors.secondary.opacity(0.16) : AppColors.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(selectedAnswer == index ? AppColors.secondary : AppColors.cardElevated, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                PrimaryButton(title: currentQuestionIndex == quiz.questions.count - 1 ? "Finish quiz" : "Next question") {
                    if currentQuestionIndex < quiz.questions.count - 1 {
                        currentQuestionIndex += 1
                        selectedAnswer = selectedAnswers[currentQuestionIndex]
                    } else {
                        hasSubmitted = true
                    }
                }
                .disabled(selectedAnswers[currentQuestionIndex] == nil)
                .opacity(selectedAnswers[currentQuestionIndex] == nil ? 0.55 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 18)
            }
            .padding(.top, 20)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(quiz.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $hasSubmitted) {
            QuizResultView(quiz: quiz, selectedAnswers: selectedAnswers)
                .environmentObject(router)
                .environmentObject(data)
        }
    }
}
