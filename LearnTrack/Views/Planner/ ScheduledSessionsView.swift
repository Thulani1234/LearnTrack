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
                    Label("Calendar Events", systemImage: "calendar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
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
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Text(event.startDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 2, height: 20)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                if let location = event.location {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "calendar")
                .foregroundColor(.green.opacity(0.5))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
    }
}

