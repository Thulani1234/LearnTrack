//
//  NotificationsHistoryView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-05-11.
//

import SwiftUI
import Combine

struct NotificationsHistoryView: View {
    @EnvironmentObject var router: AppRouter
    @State private var notifications: [ReceivedNotification] = []
    @State private var refreshTrigger = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
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
                    
                    Text("Notifications")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        NotificationManager.shared.clearReceivedNotifications()
                        refreshNotifications()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.error)
                            .font(.headline)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Clear notifications")
                    .accessibilityHint("Delete all notification history")
                }
                .padding()
                
                if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                        
                        Text("No Notifications")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Push notifications you receive while using the app will appear here")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(notifications) { notification in
                                NotificationCard(notification: notification)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            refreshNotifications()
        }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
            refreshNotifications()
        }
    }
    
    private func refreshNotifications() {
        notifications = NotificationManager.shared.getReceivedNotifications()
    }
}

struct NotificationCard: View {
    let notification: ReceivedNotification
    
    var statusIcon: String {
        if notification.type.contains("tapped") {
            return "hand.tap.fill"
        }
        return "bell.fill"
    }
    
    var statusColor: Color {
        if notification.type.contains("tapped") {
            return AppColors.success
        }
        return AppColors.primary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: statusIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(notification.body)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        Text(notification.formattedTime)
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        Text("•")
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        Text(notification.type)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NotificationsHistoryView()
        .environmentObject(AppRouter())
}
