#if canImport(ActivityKit)
import ActivityKit
#endif
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
#if canImport(ActivityKit)
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

// MARK: - Activity Manager
class StudyActivityManager {
    static let shared = StudyActivityManager()
    
    private var currentActivity: Activity<StudySessionAttributes>?
    
    func startSession(subject: String, icon: String, colorHex: String, duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
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
        
        do {
            currentActivity = try Activity.request(attributes: attributes, content: .init(state: initialState, staleDate: nil))
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateSession(elapsed: TimeInterval, progress: Double, isPaused: Bool) {
        Task {
            guard let activity = currentActivity else { return }
            let updatedState = StudySessionAttributes.ContentState(
                subject: activity.attributes.subject,
                icon: "timer", // Dynamic updates could change icon if needed
                colorHex: "6366F1",
                totalDuration: activity.attributes.totalDuration,
                elapsedTime: elapsed,
                progress: progress,
                isPaused: isPaused
            )
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }
    
    func endSession() {
        Task {
            for activity in Activity<StudySessionAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            currentActivity = nil
        }
    }
}

// MARK: - Live Activity Widget
struct StudySessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudySessionAttributes.self) { context in
            // Lock Screen / Notification View
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: context.state.colorHex).opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: context.state.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: context.state.colorHex))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text(context.attributes.subject)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Focus Session")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("/ \(formatDuration(context.attributes.totalDuration))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        // Custom Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(LinearGradient(colors: [Color(hex: context.state.colorHex), .white], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(context.state.progress), height: 6)
                                    .shadow(color: Color(hex: context.state.colorHex).opacity(0.5), radius: 4)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text("\(Int(context.state.progress * 100))% Complete")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            HStack(spacing: 16) {
                                Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: context.state.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: context.state.colorHex))
                    Text(context.attributes.subject)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: context.state.colorHex))
            } minimal: {
                Image(systemName: context.state.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: context.state.colorHex))
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

// MARK: - Lock Screen View
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<StudySessionAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                        Text("LIVE FOCUS")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.6))
                    
                    Text(context.attributes.subject)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTime(context.state.elapsedTime))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("of \(formatDuration(context.attributes.totalDuration)) session")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    ActivityControlButton(icon: context.state.isPaused ? "play.fill" : "pause.fill", color: .white.opacity(0.2))
                    ActivityControlButton(icon: "stop.fill", color: .red.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color(hex: context.state.colorHex), Color(hex: context.state.colorHex).opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct ActivityControlButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
#endif
