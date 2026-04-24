//
//  PlanSetupView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct PlanSetupView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedDuration = 0
    @State private var selectedDays: Set<Int> = [0, 1, 2, 3, 4]
    @State private var selectedPriority = 0
    
    private let durations = ["1h", "2h", "3h", "4h+"]
    private let priorities = ["Exam date first", "Weakest subject first", "Balanced mix"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppColors.textPrimary)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    Text("Create Study Plan")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Set your preferences and LearnTrack will build a personalized plan.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How many hours per day?")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    HStack(spacing: 12) {
                        ForEach(durations.indices, id: \.self) { index in
                            let duration = durations[index]
                            Button(action: { selectedDuration = index }) {
                                Text(duration)
                                    .font(AppTypography.body)
                                    .foregroundColor(selectedDuration == index ? .white : AppColors.textPrimary)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedDuration == index ? AppColors.primary : AppColors.cardBackground)
                                    .cornerRadius(14)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Which days can you study?")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    HStack(spacing: 10) {
                        ForEach(0..<7) { index in
                            Text(Calendar.current.shortWeekdaySymbols[index])
                                .font(AppTypography.caption)
                                .foregroundColor(selectedDays.contains(index) ? .white : AppColors.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(selectedDays.contains(index) ? AppColors.primary : AppColors.cardBackground)
                                .cornerRadius(12)
                                .onTapGesture {
                                    if selectedDays.contains(index) {
                                        selectedDays.remove(index)
                                    } else {
                                        selectedDays.insert(index)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How should we prioritise?")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    VStack(spacing: 12) {
                        ForEach(priorities.indices, id: \.self) { index in
                            Button(action: { selectedPriority = index }) {
                                HStack {
                                    Text(priorities[index])
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    if selectedPriority == index {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                PrimaryButton(title: "Generate My Plan") {
                    router.navigate(to: .planGenerated)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
