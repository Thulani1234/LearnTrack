import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    let icon: String
}

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
    let notifications: [NotificationItem] = [
        .init(title: "Study Reminder", message: "Your planned session starts in 15 minutes.", time: "Now", icon: "bell.fill"),
        .init(title: "Quiz Completed", message: "You scored 8/10 in Algebra Quiz.", time: "1h ago", icon: "checkmark.circle.fill"),
        .init(title: "New Session", message: "A new session has been scheduled for tomorrow.", time: "Yesterday", icon: "calendar"),
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ForEach(notifications) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .foregroundColor(AppColors.primary)
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
                        }
                        Spacer()
                        Text(item.time)
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
            .padding(.bottom, 20)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
