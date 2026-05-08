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
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
    private var notifications: [NotificationItem] {
        generateNotifications()
    }

    private func generateNotifications() -> [NotificationItem] {
        var items: [NotificationItem] = []
        let firstName = appState.currentUser?.name.split(separator: " ").first.map(String.init) ?? "Learner"
        let now = Date()

        let upcomingSession = data.scheduledSessions.sorted { $0.date < $1.date }.first
        let latestResult = data.academicResults.sorted { $0.date > $1.date }.first
        let latestSession = data.recentSessions.sorted { $0.date > $1.date }.first

        // Appreciation / Achievement notification
        if let result = latestResult {
            let scorePct = Double(result.score) / Double(max(result.maxScore, 1))
            if scorePct >= 0.9 {
                items.append(NotificationItem(
                    title: "Well done, \(firstName)!",
                    message: "Your latest score for \(result.title) is \(result.score)/\(result.maxScore). Keep up this winning streak! 🌟",
                    time: timeText(for: result.date, from: now),
                    icon: "star.fill",
                    color: .yellow,
                    type: .success
                ))
            } else if scorePct < 0.65 {
                items.append(NotificationItem(
                    title: "Study warning for \(result.title)",
                    message: "Your latest result is \(result.score)/\(result.maxScore). Let's focus on this topic with a fresh review plan. 📘",
                    time: timeText(for: result.date, from: now),
                    icon: "exclamationmark.triangle.fill",
                    color: .red,
                    type: .warning
                ))
            }
        }

        // Motivation notification based on recent session activity
        if let session = latestSession,
           let subject = data.subjects.first(where: { $0.id == session.subjectId }) {
            items.append(NotificationItem(
                title: "Keep going, \(firstName)!",
                message: "You studied \(subject.name) for \(session.durationSeconds / 60)m recently. Small daily wins build big progress. 💪",
                time: timeText(for: session.date, from: now),
                icon: "quote.bubble.fill",
                color: .blue,
                type: .motivation
            ))
        }

        // Study reminder for next scheduled session
        if let upcoming = upcomingSession,
           let subject = data.subjects.first(where: { $0.id == upcoming.subjectId }) {
            items.append(NotificationItem(
                title: "Upcoming study session",
                message: "You have \(subject.name) scheduled for \(formattedDate(upcoming.date)). Stay focused and start strong! ⏰",
                time: timeText(for: upcoming.date, from: now),
                icon: "clock.fill",
                color: .purple,
                type: .info
            ))
        }

        // Fallback notification if no dynamic activity exists
        if items.isEmpty {
            items.append(NotificationItem(
                title: "Hello, \(firstName)!",
                message: "Start your learning journey with a new study plan today. Your next achievement is waiting! 🌱",
                time: "Just now",
                icon: "sparkles",
                color: .green,
                type: .motivation
            ))
        }

        return items
    }

    private func timeText(for date: Date, from now: Date) -> String {
        let minutes = Int(now.timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        return "\(Calendar.current.dateComponents([.day], from: date, to: now).day ?? 1)d ago"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
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
