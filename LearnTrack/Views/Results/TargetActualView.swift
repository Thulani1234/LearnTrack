import SwiftUI

struct TargetActualView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    
    private var subjects: [Subject] { data.subjects }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                    Text("Target vs Actual")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("How close are you to your goals?")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    LegendChip(color: AppColors.primary, label: "Target")
                    LegendChip(color: AppColors.accent, label: "Actual")
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(subjects) { subject in
                        TargetActualCard(subject: subject)
                    }
                }
                .padding(.horizontal)
                
                ActionNeededCard()
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
            .padding(.top, 20)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct TargetActualCard: View {
    var subject: Subject
    
    var delta: Int {
        subject.currentScore - subject.targetScore
    }
    
    var statusText: String {
        if delta == 0 { return "On target" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(delta)% \(delta > 0 ? "above" : "below") target"
    }
    
    var statusColor: Color {
        if delta > 0 { return AppColors.success }
        if delta < 0 { return AppColors.error }
        return AppColors.secondary
    }
    
    var statusBackground: Color {
        statusColor.opacity(0.16)
    }
    
    var targetLabel: String {
        grade(for: subject.targetScore)
    }
    
    var actualLabel: String {
        grade(for: subject.currentScore)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon(for: subject.name))
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 38, height: 38)
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Target: \(targetLabel) (\(subject.targetScore)%)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text(statusText)
                    .font(AppTypography.caption)
                    .foregroundColor(statusColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(statusBackground)
                    .cornerRadius(12)
            }
            ProgressRow(label: "Target", grade: targetLabel, value: subject.targetScore, color: AppColors.primary)
            ProgressRow(label: "Actual", grade: actualLabel, value: subject.currentScore, color: AppColors.accent)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
    
    func grade(for score: Int) -> String {
        switch score {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        default: return "D"
        }
    }
    
    func icon(for subjectName: String) -> String {
        switch subjectName.lowercased() {
        case "english": return "book.closed.fill"
        case "science": return "flask.fill"
        case "ict": return "desktopcomputer"
        case "maths", "math": return "function"
        default: return "star.fill"
        }
    }
}

struct ProgressRow: View {
    var label: String
    var grade: String
    var value: Int
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(label): \(grade)")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("\(value)%")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.cardBackground)
                    .frame(height: 10)
                Capsule()
                    .fill(color)
                    .frame(width: CGFloat(min(value, 100)) * 2.1, height: 10)
            }
        }
    }
}

struct LegendChip: View {
    var color: Color
    var label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

struct ActionNeededCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Action needed")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text("Maths is 17% below your target grade. LearnTrack has increased Maths priority for your next study plan.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.error.opacity(0.12))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.error.opacity(0.3), lineWidth: 1)
        )
    }
}
