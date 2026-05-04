//
//  OnboardingView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    
    let steps = [
        ("Welcome to LearnTrack", "Your ultimate study companion. Plan, track, and improve your academic performance.", "book.fill"),
        ("Smart Planning", "Organize your subjects, study sessions, and track your progress effectively.", "calendar"),
        ("Track Results", "Log your exam and assessment results to visually monitor your performance over time.", "chart.line.uptrend.xyaxis"),
        ("Stay Consistent", "Get reminders, track your streaks, and build strong learning habits.", "bell.fill")
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(systemName: steps[index].2)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(AppColors.primary)
                            .padding(.bottom, 30)
                        
                        Text(steps[index].0)
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(steps[index].1)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            Spacer()
            
            PrimaryButton(title: currentStep == steps.count - 1 ? "Get Started" : "Next") {
                if currentStep < steps.count - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    appState.completeOnboarding()
                }
            }
            .padding(30)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
