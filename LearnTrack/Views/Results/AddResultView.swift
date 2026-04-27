//
//  AddResultView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct AddResultView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var title = ""
    @State private var selectedSubjectId = MockData.shared.subjects.first?.id ?? UUID()
    @State private var score = ""
    @State private var maxScore = "100"
    @State private var weight = "20"
    @State private var selectedCategory: ResultCategory = .exams
    @State private var selectedTarget = "A"
    @State private var date = Date()
    
    private let targetOptions = ["A+", "A", "B+", "B", "C+", "C", "D"]
    
    private var currentPercentage: Int? {
        guard let scoreValue = Int(score), let maxValue = Int(maxScore), maxValue > 0 else {
            return nil
        }
        return Int((Double(scoreValue) / Double(maxValue)) * 100)
    }
    
    private func targetLabel(for percentage: Int) -> String {
        switch percentage {
        case 95...100: return "A+"
        case 90..<95: return "A"
        case 85..<90: return "B+"
        case 80..<85: return "B"
        case 75..<80: return "C+"
        case 70..<75: return "C"
        default: return "D"
        }
    }
    
    private func targetScore(for label: String) -> Int {
        switch label {
        case "A+": return 95
        case "A": return 90
        case "B+": return 85
        case "B": return 80
        case "C+": return 75
        case "C": return 70
        default: return 60
        }
    }
    
    private func currentTargetLabel() -> String? {
        guard let percentage = currentPercentage else { return nil }
        return targetLabel(for: percentage)
    }
    
    private func currentTargetMarks() -> Int? {
        guard let label = currentTargetLabel() else { return nil }
        return targetScore(for: label)
    }
    
    private func updateTargetLabel() {
        guard let label = currentTargetLabel() else { return }
        selectedTarget = label
    }
    
    var body: some View {
        Form {
            Section(header: Text("Result Details")) {
                Picker("Subject", selection: $selectedSubjectId) {
                    ForEach(data.subjects) { subject in
                        Text(subject.name).tag(subject.id)
                    }
                }
                TextField("Exam/Quiz Title", text: $title)
                TextField("Score", text: $score)
                    .keyboardType(.numberPad)
                    .onChange(of: score) { _ in updateTargetLabel() }
                TextField("Max Score", text: $maxScore)
                    .keyboardType(.numberPad)
                    .onChange(of: maxScore) { _ in updateTargetLabel() }
                TextField("Weight (%)", text: $weight)
                    .keyboardType(.numberPad)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ResultCategory.allCases.filter { $0 != .all }) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                HStack {
                    Text("Target Label")
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(currentTargetLabel() ?? selectedTarget)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                HStack {
                    Text("Target Marks")
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(currentTargetMarks().map { "\($0)" } ?? "-")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section {
                PrimaryButton(title: "Save Result") {
                    saveResult()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationTitle("Add Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveResult() {
        guard let scoreValue = Int(score), let maxValue = Int(maxScore), let weightValue = Int(weight), let subjectId = data.subjects.first(where: { $0.id == selectedSubjectId })?.id else {
            return
        }
        let targetToSave = currentTargetLabel() ?? selectedTarget
        data.addResult(
            title: title.isEmpty ? "Untitled Result" : title,
            subjectId: subjectId,
            score: scoreValue,
            maxScore: maxValue,
            weight: min(max(weightValue, 1), 100),
            category: selectedCategory,
            targetLabel: targetToSave,
            date: date
        )
        router.navigateBack()
        router.navigate(to: .targetActual)
    }
}
