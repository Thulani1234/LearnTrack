//
//  CalendarService.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import EventKit
import SwiftUI
import Combine

class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var calendars: [EKCalendar] = []
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAccessToCalendar() async -> Bool {
        return await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                        continuation.resume(returning: granted)
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {
                        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authorizationStatus == .fullAccess || authorizationStatus == .writeOnly {
            loadCalendars()
        }
    }
    
    // MARK: - Calendar Management
    func loadCalendars() {
        calendars = eventStore.calendars(for: .event).filter { $0.allowsContentModifications }
    }
    
    func createLearnTrackCalendar() -> EKCalendar? {
        guard authorizationStatus == .fullAccess || authorizationStatus == .writeOnly else { return nil }
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "LearnTrack Study Sessions"
        calendar.cgColor = UIColor.systemBlue.cgColor
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            loadCalendars()
            return calendar
        } catch {
            print("Error creating calendar: \(error)")
            return nil
        }
    }
    
    // MARK: - Event Creation
    func createStudySessionEvent(
        subject: String,
        startTime: Date,
        duration: TimeInterval,
        notes: String? = nil,
        location: String? = nil
    ) async -> Bool {
        if authorizationStatus != .fullAccess && authorizationStatus != .writeOnly {
            let granted = await requestAccessToCalendar()
            guard granted else { return false }
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "Study Session: \(subject)"
        event.startDate = startTime
        event.endDate = startTime.addingTimeInterval(duration)
        event.notes = notes ?? "Study session for \(subject)"
        event.location = location
        
        // Set reminder
        let reminder = EKAlarm(relativeOffset: -15 * 60) // 15 minutes before
        event.addAlarm(reminder)
        
        // Find or create LearnTrack calendar
        let targetCalendar = calendars.first { $0.title == "LearnTrack Study Sessions" } ?? createLearnTrackCalendar()
        event.calendar = targetCalendar
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Error saving event: \(error)")
            return false
        }
    }
    
    // MARK: - Event Retrieval
    func getStudySessions(from startDate: Date, to endDate: Date) -> [EKEvent] {
        guard authorizationStatus == .fullAccess || authorizationStatus == .writeOnly else { return [] }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return eventStore.events(matching: predicate)
    }
    
    func getTodayStudySessions() -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return getStudySessions(from: startOfDay, to: endOfDay)
    }
    
    // MARK: - Event Deletion
    func deleteEvent(_ event: EKEvent) -> Bool {
        guard authorizationStatus == .fullAccess || authorizationStatus == .writeOnly else { return false }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            return true
        } catch {
            print("Error deleting event: \(error)")
            return false
        }
    }
    
    // MARK: - Utility Methods
    func formatEventDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getEventColor(for subject: String) -> Color {
        let subjectColors: [String: Color] = [
            "Math": .red,
            "Science": .green,
            "English": .blue,
            "History": .orange,
            "ICT": .purple,
            "Music": .pink
        ]
        return subjectColors[subject] ?? .gray
    }
}

// MARK: - Calendar Event Model
struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let subject: String
    let notes: String?
    let location: String?
    
    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.subject = CalendarEvent.extractSubject(from: event.title)
        self.notes = event.notes
        self.location = event.location
    }
    
    static func extractSubject(from title: String) -> String {
        if title.contains("Study Session:") {
            return title.replacingOccurrences(of: "Study Session: ", with: "")
        }
        return "General"
    }
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
}
