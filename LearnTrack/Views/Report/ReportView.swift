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
        .init(week: "W1", hours: 10),
        .init(week: "W2", hours: 15),
        .init(week: "W3", hours: 12),
        .init(week: "W4", hours: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Study Insights")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Your progress this month and a quick review of your strongest subjects.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                        .padding(12)
                        .background(AppColors.cardBackground)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                HStack(spacing: 16) {
                    ReportMetricCard(title: "Total Hours", value: "42h", subtitle: "This month")
                    ReportMetricCard(title: "Sessions", value: "18", subtitle: "Completed")
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly study pattern")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Chart(data) { item in
                            BarMark(
                                x: .value("Week", item.week),
                                y: .value("Hours", item.hours)
                            )
                            .foregroundStyle(AppColors.primary)
                            .cornerRadius(6)
                        }
                        .frame(height: 180)
                        
                        HStack(spacing: 16) {
                            ReportMiniStat(label: "Best week", value: "W4")
                            ReportMiniStat(label: "Avg / day", value: "2h 15m")
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top subjects")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    ReportSubjectCard(subject: "Mathematics", icon: "function", color: AppColors.primary, progress: 0.75, score: 92)
                    ReportSubjectCard(subject: "Science", icon: "flask.fill", color: AppColors.accent, progress: 0.58, score: 87)
                    ReportSubjectCard(subject: "English", icon: "book.closed.fill", color: AppColors.warning, progress: 0.82, score: 90)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommendation")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Spend an extra 30 minutes on Science and Maths this week to balance your subject mix and keep your overall score steady.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Reports")
        .navigationBarHidden(true)
    }
}

struct PerformanceData: Identifiable {
    var id = UUID()
    var week: String
    var hours: Int
}

struct ReportMetricCard: View {
    var title: String
    var value: String
    var subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTypography.bodySmall)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

struct ReportMiniStat: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct ReportSubjectCard: View {
    var subject: String
    var icon: String
    var color: Color
    var progress: Double
    var score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.16))
                    .cornerRadius(14)
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Score: \(score)%")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(AppTypography.headline)
                    .foregroundColor(color)
            }
            ProgressView(value: progress)
                .tint(color)
                .frame(height: 8)
                .clipShape(Capsule())
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

