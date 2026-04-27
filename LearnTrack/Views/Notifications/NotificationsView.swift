import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let icon: String
    let iconColor: Color
}

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var selectedNotification: NotificationItem?
    
    private var notifications: [NotificationItem] {
        var items: [NotificationItem] = [
            .init(
                title: "Study Reminder",
                message: "Your planned session starts in 15 minutes.",
                date: Date(),
                icon: "bell.fill",
                iconColor: AppColors.primary
            ),
            .init(
                title: "Quiz Completed",
                message: "You scored 8/10 in Algebra Quiz.",
                date: Date().addingTimeInterval(-3600),
                icon: "checkmark.circle.fill",
                iconColor: AppColors.accent
            ),
            .init(
                title: "New Session",
                message: "A new session has been scheduled for tomorrow.",
                date: Date().addingTimeInterval(-86400),
                icon: "calendar",
                iconColor: AppColors.secondary
            )
        ]
        
        // High marks appreciation
        if let recentHighScore = data.academicResults
            .sorted(by: { $0.date > $1.date })
            .first(where: { Double($0.score) / Double(max($0.maxScore, 1)) >= 0.9 }) {
            let message = "Well done! You scored \(recentHighScore.score)/\(recentHighScore.maxScore) on \(recentHighScore.title)."
            items.append(.init(
                title: "High Score Achievement",
                message: message,
                date: recentHighScore.date,
                icon: "star.circle.fill",
                iconColor: AppColors.success
            ))
        }
        
        // Low marks warnings for subjects below target
        let lowSubjects = data.subjects.filter { $0.currentScore < $0.targetScore }
        for subject in lowSubjects {
            let message = "Your current score in \(subject.name) is \(subject.currentScore)%. Keep practicing to reach \(subject.targetScore)%!"
            items.append(.init(
                title: "Low Marks Warning",
                message: message,
                date: Date().addingTimeInterval(TimeInterval(-(items.count + 1) * 1800)),
                icon: "exclamationmark.triangle.fill",
                iconColor: AppColors.warning
            ))
        }
        
        // Warning for recent low result
        if let recentLowResult = data.academicResults
            .sorted(by: { $0.date > $1.date })
            .first(where: { Double($0.score) / Double(max($0.maxScore, 1)) < 0.7 }) {
            let message = "Review the key concepts from \(recentLowResult.title) to improve your next score."
            items.append(.init(
                title: "Results Alert",
                message: message,
                date: recentLowResult.date.addingTimeInterval(TimeInterval(-1800)),
                icon: "flag.checkered",
                iconColor: AppColors.error
            ))
        }
        
        // Motivation messages
        let motivationMessages = [
            ("Keep Going!", "Every study session brings you closer to your goal."),
            ("Stay Focused", "A short review now can improve tomorrow's performance."),
            ("You’ve Got This", "Small progress each day leads to big results.")
        ]
        for (index, entry) in motivationMessages.enumerated() {
            items.append(.init(
                title: entry.0,
                message: entry.1,
                date: Date().addingTimeInterval(TimeInterval(-(index + 2) * 3600)),
                icon: "sparkles",
                iconColor: AppColors.accent
            ))
        }
        
        return items.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ForEach(notifications) { item in
                    Button(action: {
                        selectedNotification = item
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.title2)
                                .foregroundColor(item.iconColor)
                                .frame(width: 40, height: 40)
                                .background(AppColors.cardBackground)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(item.message)
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Text(item.date, style: .relative)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .alert(item: $selectedNotification) { notification in
            Alert(
                title: Text(notification.title),
                message: Text(notification.message),
                dismissButton: .default(Text("Okay"))
            )
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
