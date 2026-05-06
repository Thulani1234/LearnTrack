//
//  CalendarIntegrationView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI
import EventKit

struct CalendarIntegrationView: View {
    @StateObject private var calendarService = CalendarService()
    @State private var selectedSubject = "Math"
    @State private var studyDate = Date()
    @State private var studyDuration: Double = 60 // minutes
    @State private var studyNotes = ""
    @State private var studyLocation = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var todayEvents: [CalendarEvent] = []
    
    let subjects = ["Math", "Science", "English", "History", "ICT", "Music"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    calendarHero
                    
                    // Authorization Status
                    authorizationStatusView
                    
                    if calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly {
                        // Today's Study Sessions
                        todaySessionsView
                        
                        // Create New Study Session
                        createSessionView
                        
                        // Calendar Events List
                        eventsListView
                    }
                }
                .padding()
            }
            .navigationTitle("Calendar Integration")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTodayEvents()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var calendarHero: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 74, height: 74)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Study Calendar")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text("Plan sessions, save reminders, and keep your learning week visible.")
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(18)
        .background(AppColors.cardBackground)
        .cornerRadius(26)
        .shadow(color: Color.black.opacity(0.04), radius: 18, x: 0, y: 10)
    }
    
    // MARK: - Authorization Status View
    private var authorizationStatusView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly ? "checkmark.seal.fill" : "lock.open.trianglebadge.exclamationmark")
                    .font(.system(size: 24))
                    .foregroundColor(calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly ? AppColors.success : AppColors.warning)
                    .frame(width: 48, height: 48)
                    .background((calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly ? AppColors.success : AppColors.warning).opacity(0.12))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calendar Access")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(authorizationStatusText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if calendarService.authorizationStatus != .fullAccess && calendarService.authorizationStatus != .writeOnly {
                    Button("Request Access") {
                        requestCalendarAccess()
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .cornerRadius(14)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
        }
    }
    
    // MARK: - Today's Sessions View
    private var todaySessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Study Sessions")
                .font(.headline)
                .fontWeight(.semibold)
            
            if todayEvents.isEmpty {
                EmptyCalendarCard(title: "No study sessions today", icon: "calendar.badge.plus")
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(todayEvents) { event in
                        EventRowView(event: event, calendarService: calendarService)
                    }
                }
            }
        }
    }
    
    // MARK: - Create Session View
    private var createSessionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create Study Session")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Subject Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subject")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(subjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Date and Time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date & Time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DatePicker("Study Time", selection: $studyDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Slider(value: $studyDuration, in: 15...180, step: 15)
                        Text("\(Int(studyDuration)) min")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 60)
                    }
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Add study notes...", text: $studyNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                }
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Study location...", text: $studyLocation)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Create Button
                Button(action: createStudySession) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Create Study Session")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
        }
    }
    
    // MARK: - Events List View
    private var eventsListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Sessions")
                .font(.headline)
                .fontWeight(.semibold)
            
            let upcomingEvents = calendarService.getStudySessions(
                from: Date(),
                to: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            )
            
            if upcomingEvents.isEmpty {
                EmptyCalendarCard(title: "No upcoming sessions", icon: "calendar.badge.plus")
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(upcomingEvents.prefix(5)), id: \.eventIdentifier) { event in
                        EventRowView(event: CalendarEvent(event: event), calendarService: calendarService)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private var authorizationStatusText: String {
        switch calendarService.authorizationStatus {
        case .fullAccess:
            return "Full calendar access granted"
        case .writeOnly:
            return "Write-only calendar access granted"
        case .denied:
            return "Calendar access denied"
        case .restricted:
            return "Calendar access restricted"
        case .notDetermined:
            return "Calendar access not requested"
        @unknown default:
            return "Unknown status"
        }
    }
    
    private func requestCalendarAccess() {
        Task {
            let granted = await calendarService.requestAccessToCalendar()
            await MainActor.run {
                if granted {
                    alertTitle = "Success"
                    alertMessage = "Calendar access granted! You can now create study sessions."
                } else {
                    alertTitle = "Access Denied"
                    alertMessage = "Calendar access was denied. Please enable it in Settings to use calendar features."
                }
                showingAlert = true
                loadTodayEvents()
            }
        }
    }
    
    private func createStudySession() {
        Task {
            let success = await calendarService.createStudySessionEvent(
                subject: selectedSubject,
                startTime: studyDate,
                duration: studyDuration * 60,
                notes: studyNotes.isEmpty ? nil : studyNotes,
                location: studyLocation.isEmpty ? nil : studyLocation
            )
            
            await MainActor.run {
                if success {
                    alertTitle = "Success"
                    alertMessage = "Study session created successfully!"
                    
                    // Reset form
                    studyDate = Date()
                    studyDuration = 60
                    studyNotes = ""
                    studyLocation = ""
                    
                    loadTodayEvents()
                } else {
                    alertTitle = "Error"
                    alertMessage = "Failed to create study session. Please try again."
                }
                showingAlert = true
            }
        }
    }
    
    private func loadTodayEvents() {
        if calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly {
            todayEvents = calendarService.getTodayStudySessions().map { CalendarEvent(event: $0) }
        }
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let event: CalendarEvent
    let calendarService: CalendarService
    
    var body: some View {
        HStack(spacing: 14) {
            // Time indicator
            VStack(spacing: 3) {
                Text(event.startDate, style: .time)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(calendarService.getEventColor(for: event.subject))
                Text(event.endDate, style: .time)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 64)
            .padding(.vertical, 10)
            .background(calendarService.getEventColor(for: event.subject).opacity(0.1))
            .cornerRadius(14)
            
            // Subject indicator
            Image(systemName: icon(for: event.subject))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(calendarService.getEventColor(for: event.subject))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(calendarService.formatEventDuration(event.duration))
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
    
    private func icon(for subject: String) -> String {
        switch subject.lowercased() {
        case let value where value.contains("math"): return "function"
        case let value where value.contains("science"): return "flask.fill"
        case let value where value.contains("english"): return "book.closed.fill"
        case let value where value.contains("ict"): return "laptopcomputer"
        default: return "calendar.badge.clock"
        }
    }
}

private struct EmptyCalendarCard: View {
    var title: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .frame(width: 64, height: 64)
                .background(AppColors.primary.opacity(0.12))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
}

// MARK: - Preview
struct CalendarIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarIntegrationView()
    }
}
