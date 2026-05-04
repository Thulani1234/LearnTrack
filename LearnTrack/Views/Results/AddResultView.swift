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
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "doc.text.fill.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        CustomInputField(title: "RESULT TITLE", placeholder: "Final Exam, Midterm...", text: $title)
                        
                        // Subject Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUBJECT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            Menu {
                                ForEach(data.subjects) { subject in
                                    Button(subject.name) {
                                        selectedSubjectId = subject.id
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(data.subjects.first(where: { $0.id == selectedSubjectId })?.name ?? "Select Subject")
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
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
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
            targetLabel: "A", // Default or calculated
            date: date
        )
        router.navigateBack()
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
