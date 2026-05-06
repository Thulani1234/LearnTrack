import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Mathematics", duration: 45, progress: 0.74, icon: "function", color: Color(red: 0.39, green: 0.40, blue: 0.95)))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Mathematics", duration: 45, progress: 0.74, icon: "function", color: Color(red: 0.39, green: 0.40, blue: 0.95)))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let now = Date()
        
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            let entry = SimpleEntry(date: entryDate, studySession: getStudySessionForTime(entryDate))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getStudySessionForTime(_ date: Date) -> StudySessionWidgetData {
        let hour = Calendar.current.component(.hour, from: date)
        let data = [
            StudySessionWidgetData(subject: "Math", duration: 45, progress: 0.82, icon: "function", color: Color(red: 0.39, green: 0.40, blue: 0.95)),
            StudySessionWidgetData(subject: "Science", duration: 60, progress: 0.45, icon: "flask.fill", color: Color(red: 0.08, green: 0.72, blue: 0.65)),
            StudySessionWidgetData(subject: "ICT", duration: 90, progress: 0.91, icon: "laptopcomputer", color: Color(red: 0.66, green: 0.33, blue: 0.97)),
            StudySessionWidgetData(subject: "Design", duration: 30, progress: 0.60, icon: "paintbrush.fill", color: Color(red: 0.96, green: 0.62, blue: 0.04))
        ]
        return data[hour % data.count]
    }
}

struct StudySessionWidgetData {
    let subject: String
    let duration: Int
    let progress: Double
    let icon: String
    let color: Color
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let studySession: StudySessionWidgetData
}

// MARK: - Creative Widget View
struct LearnTrackWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Premium Gradient Background
            LinearGradient(
                colors: [entry.studySession.color, entry.studySession.color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Abstract Pattern Overlay
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 150, height: 150)
                .offset(x: 60, y: -60)
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                        Text("NEXT SESSION")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if family == .systemMedium {
                        Text(entry.date, style: .time)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                // Subject Info
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: entry.studySession.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.studySession.subject)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 10))
                            Text("\(entry.studySession.duration) Minutes")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Progress Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Today's Progress")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Text("\(Int(entry.studySession.progress * 100))%")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geo.size.width * CGFloat(entry.studySession.progress), height: 8)
                                .shadow(color: .white.opacity(0.5), radius: 4)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(16)
        }
    }
}

struct LearnTrackWidget: Widget {
    let kind: String = "LearnTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LearnTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LearnTrack")
        .description("Track your study sessions with a premium experience.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

struct LearnTrackWidgets: WidgetBundle {
    var body: some Widget {
        LearnTrackWidget()
    }
}
