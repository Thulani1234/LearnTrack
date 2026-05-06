//
//  LearnTrackWidget.swift
//  LearnTrackWidget
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), studySession: StudySessionWidgetData.sample[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), studySession: StudySessionWidgetData.sample[1])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Get current hour
        let calendar = Calendar.current
        let now = Date()
        
        // Create entries for the next 24 hours
        for hourOffset in 0..<24 {
            if let entryDate = calendar.date(byAdding: .hour, value: hourOffset, to: now) {
                let studySession = getStudySessionForTime(entryDate)
                let entry = SimpleEntry(date: entryDate, studySession: studySession)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getStudySessionForTime(_ date: Date) -> StudySessionWidgetData {
        let hour = Calendar.current.component(.hour, from: date)
        return StudySessionWidgetData.sample[hour % StudySessionWidgetData.sample.count]
    }
}

// MARK: - Widget Data Model
struct StudySessionWidgetData {
    let subject: String
    let duration: Int
    let progress: Double
    let icon: String
    let colorHex: String
    let nextLabel: String
    
    static let sample = [
        StudySessionWidgetData(subject: "Mathematics", duration: 45, progress: 0.72, icon: "function", colorHex: "6366F1", nextLabel: "Next at 4:30 PM"),
        StudySessionWidgetData(subject: "Science", duration: 60, progress: 0.48, icon: "flask.fill", colorHex: "14B8A6", nextLabel: "Next at 6:00 PM"),
        StudySessionWidgetData(subject: "English", duration: 30, progress: 0.86, icon: "book.closed.fill", colorHex: "F59E0B", nextLabel: "Next at 7:15 PM"),
        StudySessionWidgetData(subject: "ICT", duration: 90, progress: 0.64, icon: "laptopcomputer", colorHex: "A855F7", nextLabel: "Next at 8:00 PM")
    ]
}

// MARK: - Simple Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let studySession: StudySessionWidgetData
}

// MARK: - Widget View
struct LearnTrackWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    
    private var accent: Color { Color(hex: entry.studySession.colorHex) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [accent, accent.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(Color.white.opacity(0.13))
                .frame(width: 142, height: 142)
                .offset(x: family == .systemSmall ? 58 : 130, y: -72)
            
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 18)
                .frame(width: 122, height: 122)
                .offset(x: family == .systemSmall ? -72 : -134, y: 82)
            
            VStack(alignment: .leading, spacing: 12) {
                header
                Spacer(minLength: 6)
                subjectBlock
                Spacer(minLength: 6)
                progressBlock
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            accent
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 13, weight: .bold))
            Text("LearnTrack")
                .font(.system(size: 13, weight: .black, design: .rounded))
            Spacer()
            Text("\(Int(entry.studySession.progress * 100))%")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.17))
                .clipShape(Capsule())
        }
        .foregroundColor(.white)
    }
    
    private var subjectBlock: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.studySession.icon)
                .font(.system(size: family == .systemSmall ? 20 : 24, weight: .bold))
                .foregroundColor(accent)
                .frame(width: family == .systemSmall ? 42 : 50, height: family == .systemSmall ? 42 : 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 3) {
                Text("NEXT SESSION")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white.opacity(0.7))
                Text(entry.studySession.subject)
                    .font(.system(size: family == .systemSmall ? 18 : 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if family != .systemSmall {
                    Text(entry.studySession.nextLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.78))
                }
            }
        }
    }
    
    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("\(entry.studySession.duration) min focus", systemImage: "timer")
                Spacer()
                if family != .systemSmall {
                    Text(entry.date, style: .time)
                }
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white.opacity(0.82))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.22))
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * CGFloat(entry.studySession.progress))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Widget Configuration
struct LearnTrackWidget: Widget {
    let kind: String = "LearnTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LearnTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LearnTrack")
        .description("Track your study sessions and progress right from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle
struct LearnTrackWidgets: WidgetBundle {
    var body: some Widget {
        LearnTrackWidget()
    }
}

// MARK: - Preview
struct LearnTrackWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LearnTrackWidgetEntryView(entry: SimpleEntry(date: Date(), studySession: StudySessionWidgetData.sample[0]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            LearnTrackWidgetEntryView(entry: SimpleEntry(date: Date(), studySession: StudySessionWidgetData.sample[1]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 99, 102, 241)
        }
        
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
