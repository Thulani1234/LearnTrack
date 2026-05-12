import SwiftUI
import Foundation

struct PlanGeneratedView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var animateItems = false
    @State private var isSaved = false
    @State private var isSavingToCalendar = false
    @State private var hasSeededPlan = false
    @State private var generatedPlanSessions: [StudySession] = []
    
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
    
    private var weeklyHours: Int {
        max(1, generatedPlanSessions.reduce(0) { $0 + $1.durationSeconds } / 3600)
    }
    
    private var weekFocus: String {
        data.subjects.first?.name ?? "Chemistry"
    }
    
    private var scheduleByDay: [(String, [StudySession])] {
        let grouped = Dictionary(grouping: generatedPlanSessions) { session in
            let weekday = Calendar.current.component(.weekday, from: session.date)
            return Calendar.current.weekdaySymbols[weekday - 1]
        }
        let orderedDays = Calendar.current.weekdaySymbols
        return orderedDays.map { day in
            (day, grouped[day] ?? [])
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
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
                                Text("Study Plan Generated")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Academic schedule optimization is complete.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)
                            
                            HStack(spacing: 12) {
                                PlanStatPill(icon: "clock.fill", value: "\(weeklyHours)h", label: "Weekly hours")
                                PlanStatPill(icon: "chart.line.uptrend.xyaxis", value: "15–25%", label: "Improvement")
                                PlanStatPill(icon: "graduationcap.fill", value: weekFocus, label: "Week focus")
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
                                Label("ACADEMIC STRATEGY", systemImage: "briefcase.fill")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(AppColors.primary)
                                    .tracking(1)
                                Spacer()
                            }
                            
                            Text("Strategic curriculum mapping concluded. Study load has been balanced across \(data.subjects.count) subjects to ensure consistent progress and academic sustainability.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        
                        // Weekly Schedule Section
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "WEEKLY SCHEDULE")
                                .padding(.horizontal)
                            
                            VStack(spacing: 18) {
                                ForEach(scheduleByDay.filter { !$0.1.isEmpty }, id: \.0) { weekday, sessions in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(weekday.uppercased())
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundColor(AppColors.primary)
                                        ForEach(sessions) { session in
                                    HStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(subjectAccentColor(for: session.subjectId).opacity(0.14))
                                            .frame(width: 6)

                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(data.subject(for: session.subjectId)?.name ?? "Study")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(AppColors.textPrimary)
                                                Text("\(session.date.formatted(.dateTime.hour().minute())) · \(session.durationSeconds / 60) min")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }
                                            Spacer()
                                            Text(session.isCompleted ? "Review" : "Study")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(session.isCompleted ? AppColors.warning : .white)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 18)
                                                .background(session.isCompleted ? AppColors.cardBackground : AppColors.primary)
                                                .cornerRadius(20)
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                    }
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(24)
                                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                                }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "SMART TIPS")
                                .padding(.horizontal)
                            VStack(spacing: 12) {
                                TipItem(text: "Start each session by reviewing yesterday's notes")
                                TipItem(text: "Use active recall instead of re-reading")
                                TipItem(text: "Track progress weekly to stay motivated")
                            }
                            .padding(.horizontal)
                        }
                        
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                guard !isSaved && !isSavingToCalendar else { return }
                                isSavingToCalendar = true
                                Task {
                                    if !hasSeededPlan { seedStudyPlanner() }
                                    var savedCount = 0
                                    for session in generatedPlanSessions {
                                        let subjectName = data.subject(for: session.subjectId)?.name ?? "Study"
                                        let added = await CalendarManager.shared.addStudySession(
                                            title: subjectName,
                                            startDate: session.date,
                                            endDate: session.date.addingTimeInterval(TimeInterval(session.durationSeconds)),
                                            notes: session.summary
                                        )
                                        if added { savedCount += 1 }
                                    }
                                    await MainActor.run {
                                        if savedCount > 0 {
                                            withAnimation { isSaved = true }
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        }
                                        isSavingToCalendar = false
                                    }
                                    if savedCount > 0 {
                                        await MainActor.run {
                                            router.navigate(to: .fullCalendar(selectedDate: nil))
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: isSaved ? "checkmark.seal.fill" : "calendar.badge.plus")
                                    Text(isSaved ? "Saved to Calendar" : (isSavingToCalendar ? "Saving..." : "Save to Calendar"))
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background {
                                    if isSaved {
                                        Color.green
                                    } else {
                                        LinearGradient(colors: [AppColors.secondary, AppColors.primary], startPoint: .leading, endPoint: .trailing)
                                    }
                                }
                                .cornerRadius(20)
                                .shadow(color: (isSaved ? Color.green : AppColors.primary).opacity(0.25), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isSaved || isSavingToCalendar)
                            .opacity(isSaved || isSavingToCalendar ? 0.75 : 1.0)
                            
                            Button(action: { router.navigate(to: .planSetup) }) {
                                Text("New Planner")
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
            if !hasSeededPlan {
                seedStudyPlanner()
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateItems = true
            }
        }
    }
    
    private func seedStudyPlanner() {
        guard !hasSeededPlan else { return }
        guard !data.subjects.isEmpty else { return }
        let startOfDay = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        generatedPlanSessions = data.subjects.enumerated().map { index, subject in
            let sessionDate = Calendar.current.date(byAdding: .hour, value: index * 2, to: startOfDay) ?? startOfDay
            return StudySession(
                subjectId: subject.id,
                date: sessionDate,
                durationSeconds: 45 * 60,
                isCompleted: false,
                summary: "Study session for \(subject.name)."
            )
        }
        generatedPlanSessions.forEach { session in
            data.addScheduledSession(session)
        }
        hasSeededPlan = true
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
    
    private func subjectAccentColor(for subjectId: UUID) -> Color {
        let subjectName = data.subject(for: subjectId)?.name.lowercased() ?? ""
        if subjectName.contains("math") { return AppColors.primary }
        if subjectName.contains("science") { return AppColors.secondary }
        if subjectName.contains("english") { return AppColors.accent }
        if subjectName.contains("music") { return AppColors.success }
        if subjectName.contains("physics") { return AppColors.warning }
        if subjectName.contains("chemistry") { return Color(hex: "8B5CF6") }
        return AppColors.primary
    }
}

struct PlanStatPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [AppColors.primary.opacity(0.95), AppColors.secondary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(28)
        .shadow(color: AppColors.primary.opacity(0.25), radius: 20, x: 0, y: 12)
    }
}

struct TipItem: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(AppColors.primary)
                .frame(width: 8, height: 8)
                .offset(y: 6)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(18)
        .background(AppColors.cardBackground)
        .cornerRadius(22)
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

