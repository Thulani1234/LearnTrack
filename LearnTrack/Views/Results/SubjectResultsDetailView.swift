//
//  SubjectResultsDetailView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct SubjectResultsDetailView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    var result: AcademicResult

    @State private var title: String
    @State private var score: String
    @State private var maxScore: String
    @State private var weight: String
    @State private var category: ResultCategory
    @State private var targetLabel: String
    @State private var date: Date
    @State private var subjectId: UUID

    init(result: AcademicResult) {
        self.result = result
        _title = State(initialValue: result.title)
        _score = State(initialValue: String(result.score))
        _maxScore = State(initialValue: String(result.maxScore))
        _weight = State(initialValue: String(result.weight))
        _category = State(initialValue: result.category)
        _targetLabel = State(initialValue: result.targetLabel)
        _date = State(initialValue: result.date)
        _subjectId = State(initialValue: result.subjectId)
    }

    private var subject: Subject? {
        data.subject(for: subjectId)
    }

    private let targetOptions = ["A+", "A", "B+", "C", "D"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                header
                editForm
                saveButton
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Result Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(subject?.name ?? "Result")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            Text(result.title)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            DetailSummaryCard(subject: subject, result: result)
        }
    }

    private var editForm: some View {
        VStack(spacing: 18) {
            Group {
                Picker("Subject", selection: $subjectId) {
                    ForEach(data.subjects) { subject in
                        Text(subject.name).tag(subject.id)
                    }
                }
                TextField("Result title", text: $title)
                TextField("Score", text: $score)
                    .keyboardType(.numberPad)
                TextField("Max score", text: $maxScore)
                    .keyboardType(.numberPad)
                TextField("Weight (%)", text: $weight)
                    .keyboardType(.numberPad)
                Picker("Category", selection: $category) {
                    ForEach(ResultCategory.allCases.filter { $0 != .all }) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                Picker("Target label", selection: $targetLabel) {
                    ForEach(targetOptions, id: \.self) { label in
                        Text(label).tag(label)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(24)
        }
    }

    private var saveButton: some View {
        PrimaryButton(title: "Save Changes") {
            saveChanges()
        }
        .frame(maxWidth: .infinity)
    }

    private func saveChanges() {
        guard let scoreValue = Int(score), let maxValue = Int(maxScore), let weightValue = Int(weight) else {
            return
        }

        let updated = AcademicResult(
            id: result.id,
            subjectId: subjectId,
            title: title.isEmpty ? "Untitled Result" : title,
            date: date,
            score: scoreValue,
            maxScore: maxValue,
            weight: min(max(weightValue, 1), 100),
            category: category,
            targetLabel: targetLabel
        )
        data.updateResult(updated)
        router.navigateBack()
    }
}

private struct DetailSummaryCard: View {
    var subject: Subject?
    var result: AcademicResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(result.title)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text(subject?.name ?? "General")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("\(result.percentage)%")
                    .font(AppTypography.title)
                    .foregroundColor(result.percentage >= result.targetScore ? AppColors.success : AppColors.error)
            }
            ProgressView(value: Double(result.percentage) / 100)
                .tint(result.percentage >= result.targetScore ? AppColors.success : AppColors.error)
                .frame(height: 10)
                .clipShape(Capsule())
            HStack {
                Text("Grade: \(result.grade)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("Target: \(result.targetLabel)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
    }
}
