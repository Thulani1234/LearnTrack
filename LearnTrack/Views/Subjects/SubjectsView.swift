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
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
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
    @EnvironmentObject var data: MockData
    @EnvironmentObject var router: AppRouter
    var subject: Subject
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: subject.colorHex).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: subject.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: subject.colorHex))
                }
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { router.navigate(to: .editSubject(subject)) }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                            .padding(8)
                            .background(AppColors.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red.opacity(0.6))
                            .padding(8)
                            .background(Color.red.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Text("Target: \(subject.targetScore)%")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text("\(Int(subject.progress * 100))%")
                        .font(AppTypography.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: subject.colorHex))
                }
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
        .alert("Delete Subject?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    data.deleteSubject(subject)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove '\(subject.name)' and all its associated data.")
        }
    }
}
