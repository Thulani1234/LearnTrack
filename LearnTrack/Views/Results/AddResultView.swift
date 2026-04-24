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
    
    private let targetOptions = ["A+", "A", "B+", "C", "D"]
    
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
                TextField("Max Score", text: $maxScore)
                    .keyboardType(.numberPad)
                TextField("Weight (%)", text: $weight)
                    .keyboardType(.numberPad)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ResultCategory.allCases.filter { $0 != .all }) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                Picker("Target Label", selection: $selectedTarget) {
                    ForEach(targetOptions, id: \.self) { label in
                        Text(label).tag(label)
                    }
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
        data.addResult(
            title: title.isEmpty ? "Untitled Result" : title,
            subjectId: subjectId,
            score: scoreValue,
            maxScore: maxValue,
            weight: min(max(weightValue, 1), 100),
            category: selectedCategory,
            targetLabel: selectedTarget,
            date: date
        )
        router.navigateBack()
        router.navigate(to: .targetActual)
    }
}
