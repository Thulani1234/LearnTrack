//
//  SubjectsView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//




import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Subjects")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Manage your academic curriculum.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Button(action: { router.navigate(to: .addSubject) }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 44, height: 44)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Active Study Section (Live Feel)
                VStack(alignment: .leading, spacing: 16) {
                    Text("ACTIVE NOW")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .padding(4)
                            .background(Color.green.opacity(0.2))
                            .clipShape(Circle())
                        
                        Text("24 students are studying right now")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Button("Join Live") {
                            // Join live session
                        }
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.1))
                        .foregroundColor(AppColors.primary)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
                // Subjects List
                VStack(alignment: .leading, spacing: 20) {
                    Text("YOUR CURRICULUM")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(data.subjects) { subject in
                            SubjectGridCard(subject: subject)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct SubjectGridCard: View {
    var subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: subject.colorHex).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "book.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: subject.colorHex))
                }
                Spacer()
                Text("\(Int(subject.progress * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: subject.colorHex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Target: \(subject.targetScore)%")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            ProgressView(value: subject.progress)
                .tint(Color(hex: subject.colorHex))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .clipShape(Capsule())
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}
