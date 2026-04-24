//
//  ResultsView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var selectedCategory: ResultCategory = .all

    private var results: [Result] { data.academicResults }
    private var subjects: [Subject] { data.subjects }
    
    private var filteredResults: [Result] {
        selectedCategory == .all ? results : results.filter { $0.category == selectedCategory }
    }
    
    private var averageScore: Int {
        guard !results.isEmpty else { return 0 }
        let average = results.map { $0.percentage }.reduce(0, +)
        return average / results.count
    }
    
    private var bestSubject: String {
        guard let best = results.max(by: { $0.percentage < $1.percentage }),
              let subject = subjects.first(where: { $0.id == best.subjectId }) else {
            return "—"
        }
        return "\(subject.name) \(best.percentage)%"
    }
    
    private var overallGrade: String {
        switch averageScore {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B+"
        case 60..<70: return "C"
        default: return "D"
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                header
                categoryTabs
                summaryCard
                recentResultsSection
            }
            .padding(.vertical)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Results")
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Results")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                Text("Academic performance overview")
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Button(action: { router.navigate(to: .addResult) }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ResultCategory.allCases) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category.rawValue)
                            .font(AppTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedCategory == category ? .white : AppColors.textPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(selectedCategory == category ? AppColors.primary : AppColors.cardBackground)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var summaryCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 12)
            HStack(alignment: .top, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(overallGrade)
                        .font(.system(size: 62, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Overall grade")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    SummaryRow(label: "Average score", value: "\(averageScore)%")
                    SummaryRow(label: "Results logged", value: "\(results.count)")
                    SummaryRow(label: "Best subject", value: bestSubject, valueColor: AppColors.accent)
                }
            }
            .padding(28)
        }
        .frame(height: 220)
        .padding(.horizontal)
    }
    
    private var recentResultsSection: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Recent Results")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(filteredResults) { result in
                    NavigationLink(destination: SubjectResultsDetailView(result: result)
                                    .environmentObject(data)) {
                        ResultCard(result: result, subject: subject(for: result))
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func subject(for result: Result) -> Subject {
        subjects.first(where: { $0.id == result.subjectId }) ?? subjects[0]
    }
}

private struct SummaryRow: View {
    var label: String
    var value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(AppTypography.bodySmall)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

private struct ResultCard: View {
    var result: Result
    var subject: Subject
    
    private var barProgress: Double {
        Double(result.percentage) / 100.0
    }
    
    private var statusColor: Color {
        result.percentage >= result.targetScore ? AppColors.success : AppColors.error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                iconCircle
                VStack(alignment: .leading, spacing: 8) {
                    Text(result.title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(subject.name) · \(result.date.formatted(.dateTime.month().day())) · Weight: \(result.weight)%")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(result.percentage)%")
                        .font(AppTypography.headline)
                        .foregroundColor(statusColor)
                    Text(result.grade)
                        .font(AppTypography.caption)
                        .foregroundColor(statusColor)
                }
            }
            ProgressView(value: barProgress)
                .tint(statusColor)
                .frame(height: 10)
                .clipShape(Capsule())
            HStack {
                Text("Target was: \(result.targetLabel) (\(result.targetScore)%+)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(result.targetStatus)
                    .font(AppTypography.caption)
                    .foregroundColor(statusColor)
            }
        }
        .padding(18)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }
    
    private var iconCircle: some View {
        let iconName = iconNameForSubject(subject.name)
        return ZStack {
            Circle()
                .fill(Color(hex: subject.colorHex).opacity(0.22))
                .frame(width: 52, height: 52)
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(Color(hex: subject.colorHex))
        }
    }
    
    private func iconNameForSubject(_ name: String) -> String {
        switch name.lowercased() {
        case "mathematics", "math": return "function"
        case "science": return "flask.fill"
        case "english": return "book.closed.fill"
        case "ict": return "desktopcomputer"
        default: return "graduationcap.fill"
        }
    }
}

struct SubjectResultCard: View {
    var subject: Subject
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(subject.name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Target: \\(subject.targetScore)%")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            
            Text("\\(subject.currentScore)%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(subject.currentScore >= subject.targetScore ? AppColors.success : AppColors.warning)
        }
        .cardStyle()
    }
}
