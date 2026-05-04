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
    
    // MARK: - Authorization Status View
    private var authorizationStatusView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 24))
                    .foregroundColor(calendarService.authorizationStatus == .fullAccess || calendarService.authorizationStatus == .writeOnly ? .green : .orange)
                
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
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Today's Sessions View
    private var todaySessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Study Sessions")
                .font(.headline)
                .fontWeight(.semibold)
            
            if todayEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No study sessions scheduled for today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
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
                        Image(systemName: "plus.circle.fill")
                        Text("Create Study Session")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
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
                Text("No upcoming study sessions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
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
        HStack(spacing: 12) {
            // Time indicator
            VStack {
                Text(event.startDate, style: .time)
                    .font(.caption)
                    .fontWeight(.bold)
                Text(event.endDate, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Subject indicator
            Circle()
                .fill(calendarService.getEventColor(for: event.subject))
                .frame(width: 12, height: 12)
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(calendarService.formatEventDuration(event.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct CalendarIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarIntegrationView()
    }
}
