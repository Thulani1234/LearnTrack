//
//  PlannerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedDate = Date()
    @State private var animatePulse = false
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Creative Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .tracking(1)
                        
                        Text("Study Planner")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    
                    Button(action: { router.navigate(to: .planSession) }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 48, height: 48)
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Immersive AI Plan Card
                Button(action: { router.navigate(to: .planSetup) }) {
                    ZStack(alignment: .leading) {
                        // Background Mesh Gradient
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary, Color(hex: "818CF8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Abstract Glowing Shapes
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 150, height: 150)
                            .blur(radius: 40)
                            .offset(x: 200, y: -40)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(color: .white.opacity(0.5), radius: 10)
                                }
                                .scaleEffect(animatePulse ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animatePulse)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("AI Smart Plan")
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundColor(.white)
                                    Text("OPTIMIZED FOR YOU")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.7))
                                        .tracking(1)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weekly Focus: Machine Learning")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("AI recommends 45 mins of deep focus today to stay on track for your exam.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            .padding(.top, 10)
                            
                            HStack {
                                Text("Generate New Plan")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 12)
                        }
                        .padding(28)
                    }
                    .frame(height: 240)
                    .cornerRadius(32)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 20, x: 0, y: 12)
                }
                .padding(.horizontal)
                .onAppear { animatePulse = true }
                
                // Refined Calendar Strip
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("SCHEDULE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            .tracking(2)
                        Spacer()
                        Text(selectedDate.formatted(.dateTime.month().year()))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<14) { i in
                                let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                DayItem(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                                    .onTapGesture {
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedDate = date
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Sessions List
                VStack(alignment: .leading, spacing: 24) {
                    ScheduledSessionsView(date: selectedDate)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct DayItem: View {
    var date: Date
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 60, height: 90)
        .background(isSelected ? AppColors.primary : AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}


