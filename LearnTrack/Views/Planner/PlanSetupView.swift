import SwiftUI

struct PlanSetupView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var selectedDuration = 1
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5]
    @State private var selectedStartTime = 0
    @State private var selectedBreakStyle = 1
    @State private var selectedPriority = 2
    @State private var selectedSubjects: Set<String> = []
    @State private var mainGoal = ""
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    
    private let durations = [
        ("1h", "Light", "cup.and.saucer.fill"),
        ("2h", "Moderate", "bolt.fill"),
        ("3h", "Deep Focus", "brain.head.profile.fill"),
        ("4h+", "Intense", "sparkles")
    ]
    
    private let startTimes = [
        "12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"
    ]
    
    private let breakStyles = [
        (title: "Pomodoro", subtitle: "25 min work · 5 min break", icon: "timer"),
        (title: "Long Blocks", subtitle: "50 min work · 10 min break", icon: "hourglass"),
        (title: "Focus Flow", subtitle: "90 min work · 15 min break", icon: "flame.fill")
    ]
    
    private let priorities = [
        ("Peak Performance", "Prioritize upcoming exams & deadlines", "crown.fill"),
        ("Target Mastery", "Focus on subjects needing improvement", "target"),
        ("Balanced Growth", "Even coverage across all subjects", "scalemass"),
        ("Spaced Repetition", "Scientifically-timed review cycles", "repeat")
    ]
    
    private var subjectOptions: [String] {
        if data.subjects.isEmpty {
            return ["Mathematics", "Physics", "Chemistry", "Biology", "Literature", "History", "Languages", "Computer Science"]
        }
        return data.subjects.map { $0.name }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color(hex: "EEF2FF")
                    .frame(height: 140)
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
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
                        
                        Text("Create Study Plan")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Let AI craft your perfect schedule")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "DAILY FOCUS INTENSITY")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(durations.indices, id: \.self) { index in
                                let item = durations[index]
                                Button(action: { selectedDuration = index }) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        Image(systemName: item.2)
                                            .font(.system(size: 26))
                                            .foregroundColor(selectedDuration == index ? .white : AppColors.primary)
                                        Text(item.0)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(selectedDuration == index ? .white : AppColors.textPrimary)
                                        Text(item.1)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedDuration == index ? Color.white.opacity(0.9) : AppColors.textSecondary)
                                    }
                                    .padding(22)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(selectedDuration == index ? AppColors.primary : AppColors.cardBackground)
                                    .cornerRadius(26)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "YOUR SUBJECTS")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                            ForEach(subjectOptions, id: \.self) { subject in
                                let selected = selectedSubjects.contains(subject)
                                Button(action: {
                                    if selected { selectedSubjects.remove(subject) }
                                    else { selectedSubjects.insert(subject) }
                                }) {
                                    Text(subject)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(selected ? .white : AppColors.textPrimary)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(selected ? AppColors.primary : AppColors.cardBackground)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "AVAILABLE DAYS")
                        HStack(spacing: 10) {
                            ForEach(0..<7) { index in
                                let day = Calendar.current.veryShortWeekdaySymbols[index]
                                let selected = selectedDays.contains(index)
                                Button(action: {
                                    if selected { selectedDays.remove(index) }
                                    else { selectedDays.insert(index) }
                                }) {
                                    Text(day)
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(width: 34, height: 34)
                                        .foregroundColor(selected ? .white : AppColors.textPrimary)
                                        .background(selected ? AppColors.primary : AppColors.cardBackground)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "SESSION START TIME")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(startTimes.indices, id: \.self) { index in
                                    let time = startTimes[index]
                                    let selected = selectedStartTime == index
                                    Button(action: { selectedStartTime = index }) {
                                        Text(time)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(selected ? .white : AppColors.textPrimary)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 14)
                                            .background(selected ? AppColors.primary : AppColors.cardBackground)
                                            .cornerRadius(18)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "BREAK STYLE")
                        ForEach(breakStyles.indices, id: \.self) { index in
                            let option = breakStyles[index]
                            let selected = selectedBreakStyle == index
                            Button(action: { selectedBreakStyle = index }) {
                                HStack(spacing: 14) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(selected ? .white : AppColors.primary)
                                        .padding(14)
                                        .background(selected ? AppColors.primary.opacity(0.25) : AppColors.cardBackground)
                                        .cornerRadius(16)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.title)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(selected ? .white : AppColors.textPrimary)
                                        Text(option.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundColor(selected ? Color.white.opacity(0.85) : AppColors.textSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(18)
                                .background(selected ? AppColors.primary : AppColors.cardBackground)
                                .cornerRadius(22)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "YOUR MAIN GOAL")
                        TextField("e.g. Pass my Physics exam with an A, improve my calculus fundamentals...", text: $mainGoal)
                            .padding(16)
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "EXAM / DEADLINE DATE (optional)")
                        DatePicker("", selection: $deadline, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(16)
                            .background(AppColors.cardBackground)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { router.navigate(to: .planGenerated) }) {
                        Text("Continue →")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppColors.primary)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 38)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


