//
//  StudyTimerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//
/*import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject var router: AppRouter
    var subject: Subject
    
    @State private var timeRemaining = 1500 // 25 minutes
    @State private var isActive = false
    @State private var showSummary = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Studying \\(subject.name)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(AppColors.primary)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(timeRemaining) / 1500.0)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(AppColors.primary)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: timeRemaining)
                
                Text(timeString(time: timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: 250, height: 250)
            .padding()
            
            HStack(spacing: 30) {
                Button(action: {
                    isActive.toggle()
                }) {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                
                Button(action: {
                    isActive = false
                    showSummary = true
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.error)
                        .clipShape(Circle())
                        .shadow(color: AppColors.error.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .onReceive(timer) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                isActive = false
                showSummary = true
            }
        }
        .sheet(isPresented: $showSummary) {
            SessionSummaryView(subject: subject, duration: 1500 - timeRemaining)
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
*/
import SwiftUI
import Combine

struct StudyTimerView: View {
    @EnvironmentObject var router: AppRouter
    var subject: Subject
    
    private let sessionDuration = 1500 // 25 minutes
    @State private var timeElapsed = 0
    @State private var isActive = false
    @State private var showSummary = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Studying \(subject.name)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(AppColors.primary)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(timeElapsed) / Double(sessionDuration), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(AppColors.primary)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: timeElapsed)
                
                Text(timeString(time: timeElapsed))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: 250, height: 250)
            .padding()
            
            HStack(spacing: 30) {
                // Play / Pause Button
                Button(action: {
                    isActive.toggle()
                }) {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                
                // Stop Button
                Button(action: {
                    isActive = false
                    showSummary = true
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.error)
                        .clipShape(Circle())
                        .shadow(color: AppColors.error.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        
        // Timer logic
        .onReceive(timer) { _ in
            if isActive && timeElapsed < sessionDuration {
                timeElapsed += 1
            } else if timeElapsed >= sessionDuration {
                isActive = false
                showSummary = true
            }
        }
        
        // Summary Sheet
        .sheet(isPresented: $showSummary) {
            SessionSummaryView(
                subject: subject,
                duration: timeElapsed
            )
        }
    }
    
    // Convert seconds → hh:mm:ss
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
