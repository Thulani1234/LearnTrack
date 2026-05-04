import SwiftUI
import Foundation

struct PlanGeneratedView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var animateItems = false
    @State private var isSaved = false
    
    // Dynamic sessions based on user's real subjects
    private var generatedSessions: [PlanSessionItem] {
        let subjects = data.subjects
        guard !subjects.isEmpty else {
            return [
                .init(icon: "book.fill", title: "General Study", duration: "60 min"),
                .init(icon: "pencil", title: "Revision", duration: "45 min")
            ]
        }
        
        return subjects.prefix(3).map { subject in
            PlanSessionItem(
                icon: emoji(for: subject.name),
                title: subject.name,
                duration: "\(Int.random(in: 30...90)) min"
            )
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Celebratory Header
                    ZStack {
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary, Color(hex: "818CF8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                        .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            HStack {
                                Button(action: { router.navigateBack() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                Spacer()
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                Text("Your Plan is Ready!")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("AI has optimized your study journey")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)
                            
                            HStack(spacing: 12) {
                                PlanStatPill(title: "Days", value: "18", icon: "calendar")
                                PlanStatPill(title: "Sessions", value: "\(generatedSessions.count * 18)", icon: "book.fill")
                                PlanStatPill(title: "Subjects", value: "\(data.subjects.count)", icon: "graduationcap.fill")
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        }
                        .padding(.top, 20)
                    }
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // AI Insight Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("AI STRATEGY", systemImage: "brain.head.profile.fill")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(AppColors.primary)
                                    .tracking(1)
                                Spacer()
                            }
                            
                            Text("Strategic mapping complete. We've balanced your load across \(data.subjects.count) subjects to ensure consistent progress without burnout.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        
                        // Weekly Overview Section
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "WEEKLY OVERVIEW")
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<7) { i in
                                        let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                        WeeklyDayPill(date: date, sessions: generatedSessions.count)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Timeline Section
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "THE ROAD AHEAD")
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                let today = Date()
                                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                                let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: today)!
                                
                                DayPlanCard(
                                    day: "Today",
                                    date: today.formatted(.dateTime.weekday().day()),
                                    status: "Focus",
                                    sessions: generatedSessions,
                                    summary: "\(generatedSessions.count) sessions · Optimized"
                                )
                                
                                DayPlanCard(
                                    day: "Tomorrow",
                                    date: tomorrow.formatted(.dateTime.weekday().day()),
                                    status: "Light",
                                    sessions: Array(generatedSessions.reversed().prefix(2)),
                                    summary: "2 sessions · 1h 15m"
                                )
                                
                                DayPlanCard(
                                    day: dayAfter.formatted(.dateTime.weekday()),
                                    date: dayAfter.formatted(.dateTime.day()),
                                    status: "Planned",
                                    sessions: Array(generatedSessions.prefix(1)),
                                    summary: "1 session · Review"
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: { 
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                // EventKit integration
                                CalendarManager.shared.addStudySession(
                                    title: "AI Study Journey",
                                    startDate: Date(),
                                    endDate: Date().addingTimeInterval(3600),
                                    notes: "Generated plan for \(data.subjects.count) subjects."
                                )
                                withAnimation { isSaved = true }
                                // Navigate after a delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    router.navigate(to: .fullCalendar)
                                }
                            }) {
                                HStack {
                                    if isSaved {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Saved to Calendar")
                                    } else {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Save All to Calendar")
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(isSaved ? Color.green : AppColors.primary)
                                .cornerRadius(20)
                                .shadow(color: (isSaved ? Color.green : AppColors.primary).opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            Button(action: { router.navigate(to: .planner) }) {
                                Text("Dismiss")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .offset(y: animateItems ? 0 : 50)
                    .opacity(animateItems ? 1 : 0)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateItems = true
            }
        }
    }
    
    private func emoji(for subject: String) -> String {
        let name = subject.lowercased()
        if name.contains("math") { return "function" }
        if name.contains("sci") { return "testtube.2" }
        if name.contains("hist") { return "book.closed.fill" }
        if name.contains("phys") { return "bolt.fill" }
        if name.contains("bio") { return "leaf.fill" }
        if name.contains("chem") { return "flask.fill" }
        return "book.fill"
    }
}

struct PlanStatPill: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(value)
                .font(.system(size: 14, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .opacity(0.8)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct DayPlanCard: View {
    var day: String
    var date: String
    var status: String
    var sessions: [PlanSessionItem]
    var summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day)
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(AppColors.primary)
                    Text(date)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
                Text(status)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 12) {
                ForEach(sessions) { session in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Image(systemName: session.icon)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text(session.duration)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    }
                }
            }
            
            Divider()
            
            Text(summary)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}

struct PlanSessionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let duration: String
}

struct WeeklyDayPill: View {
    let date: Date
    let sessions: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 10, weight: .black))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 14, weight: .bold))
                
                Circle()
                    .fill(sessions > 0 ? AppColors.primary : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(width: 45, height: 60)
            .background(AppColors.cardBackground)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(AppColors.primary.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

