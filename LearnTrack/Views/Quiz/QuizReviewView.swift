import SwiftUI

struct QuizReviewView: View {
    @Environment(\.dismiss) var dismiss
    var quiz: Quiz
    var selectedAnswers: [Int?]
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(quiz.questions.indices, id: \.self) { index in
                        let question = quiz.questions[index]
                        ReviewCard(question: question, selectedIndex: selectedAnswers[safe: index] ?? nil, questionNumber: index + 1)
                    }
                }
                .padding()
            }
            .navigationTitle("Review Answers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

private struct ReviewCard: View {
    var question: QuizQuestion
    var selectedIndex: Int?
    var questionNumber: Int
    
    private var selectedText: String {
        guard let selected = selectedIndex,
              question.options.indices.contains(selected) else {
            return "No answer selected"
        }
        return question.options[selected]
    }
    
    private var correctText: String {
        question.options[question.correctIndex]
    }
    
    private var isCorrect: Bool {
        selectedIndex == question.correctIndex
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Question \(questionNumber)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(isCorrect ? "Correct" : "Incorrect")
                    .font(AppTypography.caption)
                    .foregroundColor(isCorrect ? AppColors.success : AppColors.error)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background((isCorrect ? AppColors.success : AppColors.error).opacity(0.12))
                    .cornerRadius(12)
            }
            Text(question.question)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            VStack(alignment: .leading, spacing: 12) {
                AnswerRow(label: "Your answer", text: selectedText, isCorrect: isCorrect)
                AnswerRow(label: "Correct answer", text: correctText, isCorrect: true)
            }
            if let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(explanation)
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}

private struct AnswerRow: View {
    var label: String
    var text: String
    var isCorrect: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Text(text)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }
            Spacer()
            Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                .foregroundColor(isCorrect ? AppColors.success : AppColors.error)
                .font(.title3)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
