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
        SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Math", duration: 45, progress: 0.7))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Math", duration: 45, progress: 0.7))
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
        let subjects = ["Math", "Science", "English", "History", "ICT", "Music"]
        let subjectIndex = hour % subjects.count
        let progress = Double.random(in: 0.3...0.9)
        let duration = Int.random(in: 30...120)
        
        return StudySessionWidgetData(subject: subjects[subjectIndex], duration: duration, progress: progress)
    }
}

// MARK: - Widget Data Model
struct StudySessionWidgetData {
    let subject: String
    let duration: Int
    let progress: Double
}

// MARK: - Simple Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let studySession: StudySessionWidgetData
}

// MARK: - Widget View
struct LearnTrackWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                
                Text("LearnTrack")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Study Session Info
            VStack(spacing: 12) {
                Text("Next Session")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(entry.studySession.subject)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(entry.studySession.duration) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                // Progress Bar
                VStack(spacing: 4) {
                    Text("Today's Progress")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                    
                    ProgressView(value: entry.studySession.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(y: 0.8)
                    
                    Text("\(Int(entry.studySession.progress * 100))%")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.6, blue: 1.0),
                    Color(red: 0.4, green: 0.3, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
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
            LearnTrackWidgetEntryView(entry: SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Math", duration: 45, progress: 0.7)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            LearnTrackWidgetEntryView(entry: SimpleEntry(date: Date(), studySession: StudySessionWidgetData(subject: "Science", duration: 60, progress: 0.85)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
