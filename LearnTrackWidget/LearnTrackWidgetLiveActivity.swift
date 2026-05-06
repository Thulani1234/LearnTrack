//
//  LearnTrackWidgetLiveActivity.swift
//  LearnTrackWidget
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import ActivityKit
import WidgetKit
import SwiftUI
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

struct StudySessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudySessionAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(hex: context.state.colorHex))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: context.state.colorHex).opacity(0.22))
                                .frame(width: 34, height: 34)
                            Image(systemName: context.state.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: context.state.colorHex))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.subject)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text(context.state.isPaused ? "Paused" : "Focus Session")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                        Text("/ \(formatDuration(context.attributes.totalDuration))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        ProgressBar(progress: context.state.progress, color: Color(hex: context.state.colorHex))
                        
                        HStack {
                            Text("\(Int(context.state.progress * 100))% complete")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: context.state.isPaused ? "pause.circle.fill" : "timer")
                                .foregroundColor(Color(hex: context.state.colorHex))
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: context.state.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: context.state.colorHex))
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: context.state.colorHex))
            } minimal: {
                Image(systemName: context.state.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: context.state.colorHex))
            }
            .keylineTint(Color(hex: context.state.colorHex))
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<StudySessionAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.isPaused ? "pause.fill" : "sparkles")
                        Text(context.state.isPaused ? "PAUSED" : "LIVE FOCUS")
                            .tracking(1)
                    }
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.72))
                    
                    Text(context.attributes.subject)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.22), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: min(max(context.state.progress, 0), 1))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 52)
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTime(context.state.elapsedTime))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("of \(formatDuration(context.attributes.totalDuration)) session")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.68))
                }
                
                Spacer()
                
                Image(systemName: context.state.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: context.state.colorHex),
                    Color(hex: context.state.colorHex).opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct ProgressBar: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.14))
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)))
            }
        }
        .frame(height: 6)
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
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
