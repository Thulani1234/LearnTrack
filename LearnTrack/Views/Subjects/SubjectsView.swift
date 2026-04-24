//
//  SubjectsView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//




import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject var router: AppRouter
    let subjects = MockData.shared.subjects
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Your Subjects")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: { router.navigate(to: .addSubject) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ForEach(subjects) { subject in
                    SubjectCard(subject: subject)
                        .padding(.horizontal)
                        .onTapGesture {
                            // Can show details or quick actions for subject
                        }
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Subjects")
        .navigationBarHidden(true)
    }
}

struct SubjectCard: View {
    var subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(subject.name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Circle()
                    .fill(Color(hex: subject.colorHex))
                    .frame(width: 12, height: 12)
            }
            
            HStack {
                Text("Score: \\(subject.currentScore) / \\(subject.targetScore)")
                    .font(AppTypography.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("\\(Int(subject.progress * 100))%")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            ProgressBar(progress: subject.progress, color: Color(hex: subject.colorHex))
        }
        .cardStyle()
    }
}

