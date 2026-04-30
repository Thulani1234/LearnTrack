//
//  ReportView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI
import Charts

struct ReportView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var mockData: MockData
    @State private var isAnimating = false
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Dynamic Background
            BackgroundView(isAnimating: $isAnimating)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header Section
                    headerSection
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                    
                    // Hero Metrics
                    HStack(spacing: 20) {
                        HeroMetricCard(title: "Avg Score", value: "\(calculateAvgScore())%", icon: "star.fill", color: .purple, delay: 0.1)
                        HeroMetricCard(title: "Study Time", value: "42h", icon: "clock.fill", color: .blue, delay: 0.2)
                    }
                    .padding(.horizontal)
                    
                    // Weekly Progress (Area Chart)
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Weekly Progress")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text("Last 4 Weeks")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal)
                        
                        ChartCard(data: getPerformanceData())
                            .opacity(appearAnimation ? 1 : 0)
                            .scaleEffect(appearAnimation ? 1 : 0.95)
                    }
                    
                    // Subject Performance
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Subject Performance")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(mockData.subjects.enumerated()), id: \.element.id) { index, subject in
                                Button(action: {
                                    if let result = mockData.academicResults.first(where: { $0.subjectId == subject.id }) {
                                        router.navigate(to: .resultDetail(result))
                                    } else {
                                        router.navigate(to: .results)
                                    }
                                }) {
                                    ModernSubjectRow(subject: subject.name, score: subject.currentScore, progress: subject.progress, color: Color(hex: subject.colorHex), index: index)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // AI Insight Box
                    InsightCard {
                        router.navigate(to: .targetActual)
                    }
                    .padding(.horizontal)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appearAnimation = true
            }
        }
    }
    
    private func calculateAvgScore() -> Int {
        let total = mockData.subjects.reduce(0) { $0 + $1.currentScore }
        return mockData.subjects.isEmpty ? 0 : total / mockData.subjects.count
    }
    
    private func getPerformanceData() -> [PerformanceData] {
        [
            .init(week: "W1", hours: 10, color: .purple),
            .init(week: "W2", hours: 15, color: .blue),
            .init(week: "W3", hours: 12, color: .pink),
            .init(week: "W4", hours: 20, color: .orange)
        ]
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Performance Report")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("Top 5% in your class")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            Spacer()
            
            Button(action: {
                // Share functionality or navigate to notifications
                router.navigate(to: .notifications)
            }) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
                    .padding(12)
                    .background(Circle().fill(.ultraThinMaterial))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Components

struct BackgroundView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "F8FAFC").ignoresSafeArea()
            
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: isAnimating ? 150 : -100, y: isAnimating ? -200 : 250)
            
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: isAnimating ? -150 : 100, y: isAnimating ? 200 : -250)
        }
        .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: isAnimating)
    }
}

struct HeroMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var show = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .padding(10)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 10)
        .opacity(show ? 1 : 0)
        .scaleEffect(show ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                show = true
            }
        }
    }
}

struct ChartCard: View {
    let data: [PerformanceData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Chart {
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Week", item.week),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Week", item.week),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(AppColors.primary)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    
                    PointMark(
                        x: .value("Week", item.week),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(AppColors.primary)
                    .symbolSize(60)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.1))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)h")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct SubjectDistributionChart: View {
    let subjects: [Subject]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Score Distribution")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 30) {
                Chart(subjects) { subject in
                    SectorMark(
                        angle: .value("Score", subject.currentScore),
                        innerRadius: .ratio(0.65),
                        angularInset: 2
                    )
                    .cornerRadius(8)
                    .foregroundStyle(Color(hex: subject.colorHex))
                }
                .frame(width: 150, height: 150)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(subjects.prefix(4)) { subject in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: subject.colorHex))
                                .frame(width: 10, height: 10)
                            Text(subject.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text("\(subject.currentScore)%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct ModernSubjectRow: View {
    let subject: String
    let score: Int
    let progress: Double
    let color: Color
    let index: Int
    
    @State private var show = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 6)
                    .frame(width: 54, height: 54)
                Circle()
                    .trim(from: 0, to: show ? progress : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 54, height: 54)
                    .rotationEffect(.degrees(-90))
                
                Text("\(score)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Consistent Improvement")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(20)
        .background(Color.white.opacity(0.6))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        .opacity(show ? 1 : 0)
        .offset(x: show ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3)) {
                show = true
            }
        }
    }
}

struct InsightCard: View {
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundColor(.white)
                Text("AI Learning Insights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text("Your study pattern shows peak focus in the mornings. We recommend shifting Science practice to 9 AM for better retention.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.9))
            
            Button(action: action) {
                Text("View Full Analysis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(
            LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(32)
        .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct PerformanceData: Identifiable {
    var id = UUID()
    var week: String
    var hours: Int
    var color: Color
}


