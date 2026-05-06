import SwiftUI
import EventKit

struct ScheduledSessionsView: View {
    var date: Date
    @State private var calendarEvents: [EKEvent] = []
    let sessions = MockData.shared.scheduledSessions
    
    private var dailySessions: [StudySession] {
        sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Study Sessions Section
            if !dailySessions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Study Plans", systemImage: "book.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal)
                    
                    ForEach(dailySessions) { session in
                        SessionCard(session: session)
                            .padding(.horizontal)
                    }
                }
            }
            
            // Calendar Events Section
            if !calendarEvents.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Calendar Events", systemImage: "calendar.badge.clock")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.accent)
                        .padding(.horizontal)
                    
                    ForEach(calendarEvents, id: \.eventIdentifier) { event in
                        CalendarEventCard(event: event)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            
            if dailySessions.isEmpty && calendarEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    Text("Your day is clear!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .onAppear { loadCalendarEvents() }
        .onChange(of: date) { _ in loadCalendarEvents() }
    }
    
    private func loadCalendarEvents() {
        calendarEvents = CalendarManager.shared.fetchEvents(for: date)
    }
}

struct CalendarEventCard: View {
    let event: EKEvent
    
    private var subject: String {
        event.title.replacingOccurrences(of: "Study Session: ", with: "")
    }
    
    private var accent: Color {
        switch subject.lowercased() {
        case let value where value.contains("math"): return AppColors.primary
        case let value where value.contains("science"): return AppColors.accent
        case let value where value.contains("english"): return AppColors.warning
        case let value where value.contains("ict"): return AppColors.secondary
        default: return AppColors.success
        }
    }
    
    private var icon: String {
        switch subject.lowercased() {
        case let value where value.contains("math"): return "function"
        case let value where value.contains("science"): return "flask.fill"
        case let value where value.contains("english"): return "book.closed.fill"
        case let value where value.contains("ict"): return "laptopcomputer"
        default: return "calendar.badge.clock"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(event.startDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(accent)
                
                Text(event.endDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 58)
            .padding(.vertical, 10)
            .background(accent.opacity(0.1))
            .cornerRadius(16)
            
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Label("Calendar study session", systemImage: "calendar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                
                if let location = event.location {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(accent.opacity(0.7))
        }
        .padding(14)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
    }
}
