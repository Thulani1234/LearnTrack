//
//  ReportView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI
import Charts

struct ReportView: View {
    let data: [PerformanceData] = [
        .init(week: "W1", hours: 10, color: .purple),
        .init(week: "W2", hours: 15, color: .blue),
        .init(week: "W3", hours: 12, color: .pink),
        .init(week: "W4", hours: 20, color: .orange)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Academic Report")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Track your performance across all subjects.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: "chart.pie.fill")
                            .font(.title3)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Key Metrics
                HStack(spacing: 16) {
                    ReportMetricCard(title: "Avg Score", value: "88%", icon: "target", color: .purple)
                    ReportMetricCard(title: "Study Time", value: "42h", icon: "timer", color: .blue)
                }
                .padding(.horizontal)
                
                // Progress Chart
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weekly Study Progress")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Chart(data) { item in
                            BarMark(
                                x: .value("Week", item.week),
                                y: .value("Hours", item.hours)
                            )
                            .foregroundStyle(item.color.gradient)
                            .cornerRadius(10)
                        }
                        .frame(height: 200)
                        
                        HStack(spacing: 20) {
                            HStack(spacing: 8) {
                                Circle().fill(Color.orange).frame(width: 8, height: 8)
                                Text("Best: W4").font(AppTypography.caption).foregroundColor(AppColors.textSecondary)
                            }
                            HStack(spacing: 8) {
                                Circle().fill(Color.blue).frame(width: 8, height: 8)
                                Text("Avg: 14h").font(AppTypography.caption).foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(32)
                    .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
                    .padding(.horizontal)
                }
                
                // Subject Breakdown
                VStack(alignment: .leading, spacing: 20) {
                    Text("Subject Performance")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ReportSubjectRow(subject: "Mathematics", score: 92, progress: 0.85, color: .purple)
                        ReportSubjectRow(subject: "Science", score: 87, progress: 0.72, color: .blue)
                        ReportSubjectRow(subject: "English", score: 90, progress: 0.90, color: .orange)
                        ReportSubjectRow(subject: "ICT", score: 84, progress: 0.65, color: .green)
                    }
                    .padding(.horizontal)
                }
                
                // AI Suggestion
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Text("Personalized Insight")
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                    }
                    Text("You're performing above average in Mathematics! Focus more on Science this week to achieve your target of 90%.")
                        .font(AppTypography.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(24)
                .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(32)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct PerformanceData: Identifiable {
    var id = UUID()
    var week: String
    var hours: Int
    var color: Color
}

struct ReportMetricCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct ReportSubjectRow: View {
    var subject: String
    var score: Int
    var progress: Double
    var color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 4)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                Text("\(score)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("Performance: Very Good")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}


