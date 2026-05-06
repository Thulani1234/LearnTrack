#if canImport(ActivityKit)
import ActivityKit
import Foundation

struct StudySessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var subject: String
        var icon: String
        var colorHex: String
        var totalDuration: TimeInterval
        var elapsedTime: TimeInterval
        var progress: Double
        var isPaused: Bool
    }
    
    let subject: String
    let totalDuration: TimeInterval
}

final class StudyActivityManager {
    static let shared = StudyActivityManager()
    
    private var currentActivity: Activity<StudySessionAttributes>?
    private var currentIcon = "timer"
    private var currentColorHex = "6366F1"
    
    private init() {}
    
    func startSession(subject: String, icon: String, colorHex: String, duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are disabled for this device or app.")
            return
        }
        
        currentIcon = icon
        currentColorHex = colorHex
        
        let attributes = StudySessionAttributes(subject: subject, totalDuration: duration)
        let initialState = StudySessionAttributes.ContentState(
            subject: subject,
            icon: icon,
            colorHex: colorHex,
            totalDuration: duration,
            elapsedTime: 0,
            progress: 0,
            isPaused: false
        )
        
        Task {
            await endExistingActivities()
            
            do {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: nil)
                )
            } catch {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    func updateSession(elapsed: TimeInterval, progress: Double, isPaused: Bool) {
        Task {
            guard let activity = currentActivity ?? Activity<StudySessionAttributes>.activities.first else { return }
            currentActivity = activity
            
            let boundedProgress = min(max(progress, 0), 1)
            let updatedState = StudySessionAttributes.ContentState(
                subject: activity.attributes.subject,
                icon: currentIcon,
                colorHex: currentColorHex,
                totalDuration: activity.attributes.totalDuration,
                elapsedTime: elapsed,
                progress: boundedProgress,
                isPaused: isPaused
            )
            
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }
    
    func endSession() {
        Task {
            await endExistingActivities()
            currentActivity = nil
        }
    }
    
    private func endExistingActivities() async {
        for activity in Activity<StudySessionAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}
#endif
