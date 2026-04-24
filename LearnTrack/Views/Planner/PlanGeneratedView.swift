import SwiftUI

struct PlanGeneratedView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppColors.textPrimary)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    Text("Your Plan is Ready!")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Based on your goals, LearnTrack created a schedule that fits your study days.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                HStack(spacing: 16) {
                    PlanStatCard(title: "Days planned", value: "18")
                    PlanStatCard(title: "Sessions", value: "42")
                    PlanStatCard(title: "Subjects", value: "4")
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Smart suggestion")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Science exam is in 2 days — we've allocated 60 min today and 60 min tomorrow as final revision sessions.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(18)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    DayPlanCard(day: "Today — Sat 28", status: "Urgent", sessions: [
                        .init(icon: "flame.fill", title: "Science", duration: "60 min"),
                        .init(icon: "plus", title: "Maths", duration: "45 min"),
                        .init(icon: "desktopcomputer", title: "ICT", duration: "30 min")
                    ], summary: "3 sessions · 2h 15m")
                    DayPlanCard(day: "Sun 29", status: "Exam tmrw", sessions: [
                        .init(icon: "flame.fill", title: "Science", duration: "60 min"),
                        .init(icon: "plus", title: "Maths", duration: "45 min")
                    ], summary: "2 sessions · 1h 45m")
                    DayPlanCard(day: "Mon 30", status: "Planned", sessions: [
                        .init(icon: "plus", title: "Maths", duration: "60 min"),
                        .init(icon: "book.fill", title: "English", duration: "30 min")
                    ], summary: "2 sessions · 1h 30m")
                }
                .padding(.horizontal)
                
                PrimaryButton(title: "Back to Planner") {
                    router.navigate(to: .planner)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct PlanStatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
}

struct DayPlanCard: View {
    var day: String
    var status: String
    var sessions: [PlanSessionItem]
    var summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text(summary)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text(status)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.primary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(AppColors.primary.opacity(0.15))
                    .cornerRadius(12)
            }
            ForEach(sessions) { session in
                HStack(spacing: 12) {
                    Image(systemName: session.icon)
                        .foregroundColor(AppColors.primary)
                        .frame(width: 30, height: 30)
                        .background(AppColors.cardBackground)
                        .cornerRadius(8)
                    Text(session.title)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text(session.duration)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

struct PlanSessionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let duration: String
}
