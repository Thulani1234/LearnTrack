import SwiftUI


struct AddResultView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @EnvironmentObject var appState: AppState
    @State private var title = ""
    @State private var selectedSubjectId: UUID?
    @State private var score = ""
    @State private var maxScore = "100"
    @State private var weight = "20"
    @State private var selectedCategory: ResultCategory = .exams
    @State private var date = Date()
    
    private var scoreValue: Int? { Int(score) }
    private var maxScoreValue: Int { max(Int(maxScore) ?? 100, 1) }
    private var currentPercentage: Int? {
        guard let scoreValue else { return nil }
        return Int((Double(scoreValue) / Double(maxScoreValue)) * 100)
    }
    private var targetPercentage: Int {
        Int((Double(targetMarks) / Double(maxScoreValue)) * 100)
    }
    private var targetMarks: Int {
        guard let scoreValue = scoreValue else { return maxScoreValue }
        return min(maxScoreValue, scoreValue + 10)
    }
    private var targetLabel: String {
        switch targetPercentage {
        case 95...100: return "A+"
        case 90..<95: return "A"
        case 80..<90: return "B+"
        case 70..<80: return "B"
        case 60..<70: return "C"
        default: return "D"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.textPrimary)
                        .font(.headline)
                        .padding(12)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
                Spacer()
                Text("Add Result")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Success Illustration / Icon
                    ResultPreviewCard(
                        subjectName: selectedSubjectName,
                        percentage: currentPercentage,
                        targetLabel: targetLabel,
                        targetPercentage: targetPercentage,
                        targetMarks: targetMarks,
                        maxMarks: maxScoreValue
                    )
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        CustomInputField(title: "RESULT TITLE", placeholder: "Final Exam, Midterm, Assignment...", text: $title)
                        
                        // Subject Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUBJECT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            Menu {
                                ForEach(data.subjects) { subject in
                                    Button(action: {
                                        selectedSubjectId = subject.id
                                    }) {
                                        Label(subject.name, systemImage: subject.icon)
                                    }
                                }
                                
                                if data.subjects.isEmpty {
                                    Button("Create a subject first") {
                                        router.navigate(to: .addSubject)
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    if let selectedIcon = selectedSubjectIcon {
                                        Image(systemName: selectedIcon)
                                            .foregroundColor(AppColors.primary)
                                    }
                                    Text(selectedSubjectName)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                            }
                        }
                        
                        // Scores
                        HStack(spacing: 20) {
                            CustomInputField(title: "SCORE", placeholder: "85", text: $score, keyboardType: .numberPad)
                            CustomInputField(title: "MAX SCORE", placeholder: "100", text: $maxScore, keyboardType: .numberPad)
                        }
                        
                        // Weight & Category
                        HStack(spacing: 20) {
                            CustomInputField(title: "WEIGHT (%)", placeholder: "20", text: $weight, keyboardType: .numberPad)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("CATEGORY")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                
                                Menu {
                                    ForEach(ResultCategory.allCases.filter { $0 != .all }) { category in
                                        Button(category.rawValue) {
                                            selectedCategory = category
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCategory.rawValue)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(16)
                                }
                            }
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DATE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TARGET MARKS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            HStack {
                                Text("\(targetMarks)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text("of \(maxScoreValue)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveResult) {
                        Text("Save Performance")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .cornerRadius(20)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .disabled(data.subjects.isEmpty)
                    .opacity(data.subjects.isEmpty ? 0.55 : 1)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if selectedSubjectId == nil {
                selectedSubjectId = data.subjects.first?.id
            }
        }
    }
    
    private var selectedSubjectIcon: String? {
        guard let selectedSubjectId = self.selectedSubjectId,
              let subject = data.subjects.first(where: { $0.id == selectedSubjectId }) else {
            return nil
        }
        return subject.icon
    }
    
    private var selectedSubjectName: String {
        guard let selectedSubjectId = self.selectedSubjectId,
              let subject = data.subjects.first(where: { $0.id == selectedSubjectId }) else {
            return data.subjects.isEmpty ? "No subjects yet" : "Select Subject"
        }
        return subject.name
    }
    
    private func saveResult() {
        guard !data.subjects.isEmpty else {
            appState.currentAlert = AppAlert(
                title: "Add a Subject First",
                message: "Create a subject before saving academic results.",
                icon: "books.vertical.fill",
                color: AppColors.primary,
                type: .info
            )
            router.navigate(to: .addSubject)
            return
        }
        
        guard let selectedSubjectId = self.selectedSubjectId,
              let scoreValue = Int(score),
              let maxValue = Int(maxScore),
              maxValue > 0,
              let weightValue = Int(weight),
              let selectedSubject = data.subjects.first(where: { $0.id == selectedSubjectId }) else {
            appState.currentAlert = AppAlert(
                title: "Check Result Details",
                message: "Add a subject, score, max score, and weight before saving.",
                icon: "exclamationmark.triangle.fill",
                color: AppColors.warning,
                type: .warning
            )
            return
        }
        let subjectId = selectedSubject.id
        
        data.addResult(
            title: title.isEmpty ? "Untitled Result" : title,
            subjectId: subjectId,
            score: scoreValue,
            maxScore: maxValue,
            weight: min(max(weightValue, 1), 100),
            category: selectedCategory,
            targetLabel: targetLabel,
            date: date
        )
        
        appState.currentAlert = AppAlert(
            title: "Result Saved",
            message: "Your \(selectedCategory.rawValue.lowercased()) result has been added.",
            icon: "chart.bar.fill",
            color: AppColors.success,
            type: .success
        )
        router.navigateBack()
    }
}

private struct ResultPreviewCard: View {
    var subjectName: String
    var percentage: Int?
    var targetLabel: String
    var targetPercentage: Int
    var targetMarks: Int
    var maxMarks: Int
    
    private var statusColor: Color {
        guard let percentage else { return AppColors.primary }
        return percentage >= targetPercentage ? AppColors.success : AppColors.warning
    }
    
    private var statusText: String {
        guard let percentage else { return "Enter marks to preview performance" }
        if percentage >= targetPercentage {
            return "Target reached"
        }
        return "\(targetPercentage - percentage)% below target"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.14))
                        .frame(width: 58, height: 58)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(subjectName)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text(statusText)
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(percentage.map { "\($0)%" } ?? "—")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(statusColor)
            }
            
            HStack(spacing: 12) {
                PreviewMetric(label: "Target", value: "\(targetLabel) / \(targetPercentage)%")
                PreviewMetric(label: "Need", value: "\(targetMarks)/\(maxMarks)")
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 18, x: 0, y: 10)
        .padding(.horizontal)
    }
}

private struct PreviewMetric: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black))
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppColors.background)
        .cornerRadius(14)
    }
}

struct CustomInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        }
    }
}
