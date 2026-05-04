import SwiftUI

struct PlanSetupView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedDuration = 1
    @State private var selectedDays: Set<Int> = [0, 1, 2, 3, 4]
    @State private var selectedPriority = 2
    
    private let durations = [
        ("1h", "Light", "cup.and.saucer.fill"),
        ("2h", "Moderate", "bolt.fill"),
        ("3h", "Deep Focus", "brain.head.profile.fill"),
        ("4h+", "Intense", "sparkles")
    ]
    
    private let priorities = [
        ("Peak Performance", "Prioritize upcoming exams & deadlines", "crown.fill"),
        ("Target Mastery", "Focus on subjects needing improvement", "target"),
        ("Steady Growth", "Maintain balanced progress across all subjects", "chart.line.uptrend.xyaxis")
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Creative Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: { router.navigateBack() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(12)
                                    .background(AppColors.cardBackground)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create Study Plan")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Let AI build your perfect schedule.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Duration Selection (Visual Cards)
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "DAILY FOCUS INTENSITY")
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(durations.indices, id: \.self) { index in
                                let item = durations[index]
                                Button(action: { 
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    selectedDuration = index 
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: item.2)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedDuration == index ? .white : AppColors.primary)
                                        
                                        VStack(spacing: 2) {
                                            Text(item.0)
                                                .font(.system(size: 18, weight: .bold))
                                            Text(item.1)
                                                .font(.system(size: 10, weight: .bold))
                                                .opacity(0.8)
                                        }
                                        .foregroundColor(selectedDuration == index ? .white : AppColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(selectedDuration == index ? AppColors.primary : AppColors.cardBackground)
                                    .cornerRadius(24)
                                    .shadow(color: selectedDuration == index ? AppColors.primary.opacity(0.3) : Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(selectedDuration == index ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Day Selection (Refined)
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "AVAILABLE DAYS")
                        
                        HStack(spacing: 8) {
                            ForEach(0..<7) { index in
                                let day = Calendar.current.veryShortWeekdaySymbols[index]
                                let isSelected = selectedDays.contains(index)
                                
                                Text(day)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(isSelected ? AppColors.primary : AppColors.cardBackground)
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        if isSelected {
                                            selectedDays.remove(index)
                                        } else {
                                            selectedDays.insert(index)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Priority Section (List Cards)
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "STRATEGIC PRIORITY")
                        
                        VStack(spacing: 12) {
                            ForEach(priorities.indices, id: \.self) { index in
                                let item = priorities[index]
                                Button(action: { selectedPriority = index }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedPriority == index ? Color.white.opacity(0.2) : AppColors.primary.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: item.2)
                                                .foregroundColor(selectedPriority == index ? .white : AppColors.primary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.0)
                                                .font(.system(size: 16, weight: .bold))
                                            Text(item.1)
                                                .font(.system(size: 12))
                                                .opacity(0.7)
                                        }
                                        .foregroundColor(selectedPriority == index ? .white : AppColors.textPrimary)
                                        
                                        Spacer()
                                        
                                        if selectedPriority == index {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(16)
                                    .background(selectedPriority == index ? AppColors.primary : AppColors.cardBackground)
                                    .cornerRadius(20)
                                    .shadow(color: selectedPriority == index ? AppColors.primary.opacity(0.2) : Color.clear, radius: 10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Generate Button (Premium)
                    Button(action: { router.navigate(to: .planGenerated) }) {
                        HStack {
                            Text("Build My AI Plan")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "sparkles")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(24)
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

