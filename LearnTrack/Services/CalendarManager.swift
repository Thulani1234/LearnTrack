import EventKit
import SwiftUI
import Combine

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    @Published var isAuthorized = false
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            DispatchQueue.main.async { self.isAuthorized = true }
        case .notDetermined:
            requestAccess()
        default:
            DispatchQueue.main.async { self.isAuthorized = false }
        }
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func addStudySession(title: String, startDate: Date, endDate: Date, notes: String? = nil) {
        guard isAuthorized else {
            requestAccess()
            return
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "Study Session: \(title)"
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Successfully saved study session to calendar.")
        } catch {
            print("Error saving event to calendar: \(error.localizedDescription)")
        }
    }
    
    func scheduleReminder(title: String, dueDate: Date) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted else { return }
            
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = "Time to Study: \(title)"
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            
            do {
                try self.eventStore.save(reminder, commit: true)
            } catch {
                print("Error saving reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchEvents(for date: Date) -> [EKEvent] {
        guard isAuthorized else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        return eventStore.events(matching: predicate)
    }
}
