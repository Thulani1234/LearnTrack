import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    let icon: String
    let color: Color
    let type: NotificationType
}

enum NotificationType {
    case warning, success, info, motivation
}

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
    
    let notifications = [
        NotificationItem(title: "High Marks Appreciation", message: "Brilliant! You scored 98% in Science. Your dedication is truly inspiring! 🌟", time: "Just now", icon: "star.fill", color: .yellow, type: .success),
        NotificationItem(title: "Low Marks Warning", message: "Heads up! Your Maths score (45%) is below your target. Don't worry, let's review together! 📚", time: "30m ago", icon: "exclamationmark.triangle.fill", color: .red, type: .warning),
        NotificationItem(title: "Daily Motivation", message: "Success is the sum of small efforts repeated daily. Keep pushing, Sara! 💪", time: "2h ago", icon: "quote.bubble.fill", color: .blue, type: .motivation),
        NotificationItem(title: "Study Reminder", message: "Time to start your Science session. You've got this!", time: "10m ago", icon: "clock.fill", color: .purple, type: .info),
        NotificationItem(title: "New Achievement", message: "Congratulations! You've reached a 7-day study streak.", time: "2h ago", icon: "flame.fill", color: .orange, type: .success),
        NotificationItem(title: "Quiz Result", message: "Your English quiz result is out. You scored 92%!", time: "Yesterday", icon: "pencil.and.outline", color: .blue, type: .success),
        NotificationItem(title: "Goal Reached", message: "You completed all your planned sessions for today.", time: "Yesterday", icon: "target", color: .green, type: .info),
        NotificationItem(title: "Subject Update", message: "Mathematics syllabus has been updated with new materials.", time: "2 days ago", icon: "books.vertical.fill", color: .pink, type: .info)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Creative Header
            ZStack(alignment: .bottom) {
                AppColors.cardBackground
                    .ignoresSafeArea()
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                HStack {
                    Button(action: { router.navigateBack() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.system(size: 18, weight: .bold))
                            .padding(12)
                            .background(AppColors.background)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Notifications")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        NotificationManager.shared.sendImmediateNotification(
                            title: "LearnTrack Live Alert ⚡️",
                            body: "This is a push notification! It shows even while you are using the app."
                        )
                    }) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(AppColors.primary)
                            .padding(10)
                            .background(AppColors.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {}) {
                        Text("Clear All")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding()
            }
            .frame(height: 70)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(notifications) { notification in
                        NotificationRow(notification: notification)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with Glow
            ZStack {
                Circle()
                    .fill(notification.color.opacity(0.1))
                    .frame(width: 54, height: 54)
                
                Image(systemName: notification.icon)
                    .foregroundColor(notification.color)
                    .font(.system(size: 22))
                    .shadow(color: notification.color.opacity(0.3), radius: 5, x: 0, y: 0)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(notification.time)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                }
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(notification.type == .warning ? Color.red.opacity(0.2) : (notification.type == .success ? Color.green.opacity(0.2) : Color.clear), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 8)
    }
}
