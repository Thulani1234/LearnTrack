import SwiftUI
import Combine

struct StudyTimerView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    
    var initialSubject: Subject
    @State private var currentSubject: Subject
    
    private let sessionDuration = 1500 // 25 minutes
    @State private var timeElapsed = 0
    @State private var isActive = false
    @State private var showSummary = false
    @State private var showHistory = false
    
    @State private var pulseAmount: CGFloat = 1.0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let quotes = [
        "Focus on the step, not the mountain.",
        "Your future self will thank you.",
        "Small progress is still progress.",
        "Don't stop until you're proud.",
        "Deep work is the superpower of the 21st century."
    ]
    @State private var currentQuote = "Focus on the step, not the mountain."
    
    init(subject: Subject) {
        self.initialSubject = subject
        self._currentSubject = State(initialValue: subject)
    }
    
    var subjectColor: Color {
        Color(hex: currentSubject.colorHex)
    }
    
    var body: some View {
        ZStack {
            // Creative Background
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                // Pulsing Glow
                Circle()
                    .fill(subjectColor.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .scaleEffect(isActive ? pulseAmount : 1.0)
                    .animation(isActive ? .easeInOut(duration: 2).repeatForever(autoreverses: true) : .default, value: pulseAmount)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.navigateBack() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.headline)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Focus Session")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.headline)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Subject Selection (Refined)
                VStack(alignment: .leading, spacing: 16) {
                    Text("CURRENT SUBJECT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(data.subjects) { subj in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        currentSubject = subj
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(currentSubject.id == subj.id ? Color(hex: subj.colorHex) : AppColors.cardBackground)
                                                .frame(width: 50, height: 50)
                                            Text(emoji(for: subj.name))
                                                .font(.title2)
                                        }
                                        Text(subj.name)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(currentSubject.id == subj.id ? AppColors.textPrimary : AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 8)
                                    .frame(width: 85)
                                    .background(currentSubject.id == subj.id ? Color(hex: subj.colorHex).opacity(0.1) : Color.clear)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(currentSubject.id == subj.id ? Color(hex: subj.colorHex) : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Creative Timer Display
                ZStack {
                    // Outer decorative circle
                    Circle()
                        .stroke(subjectColor.opacity(0.1), lineWidth: 40)
                        .frame(width: 280, height: 280)
                    
                    // Background path
                    Circle()
                        .stroke(AppColors.cardBackground, lineWidth: 15)
                        .frame(width: 250, height: 250)
                    
                    // Progress path
                    Circle()
                        .trim(from: 0, to: CGFloat(min(Double(timeElapsed) / Double(sessionDuration), 1.0)))
                        .stroke(
                            subjectColor,
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timeElapsed)
                        .shadow(color: subjectColor.opacity(0.3), radius: 10, x: 0, y: 0)
                    
                    // Time Text
                    VStack(spacing: 0) {
                        Text(timeString(time: timeElapsed))
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .monospacedDigit()
                        
                        Text("ELAPSED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Quote Area
                Text(currentQuote)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(height: 60)
                    .onTapGesture {
                        withAnimation {
                            currentQuote = quotes.randomElement() ?? currentQuote
                        }
                    }
                
                // Controls
                HStack(spacing: 32) {
                    // Stop
                    Button(action: {
                        isActive = false
                        showSummary = true
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(AppColors.error)
                            .clipShape(Circle())
                            .shadow(color: AppColors.error.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Main Play/Pause
                    Button(action: {
                        withAnimation(.spring()) {
                            isActive.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(subjectColor)
                                .frame(width: 90, height: 90)
                                .shadow(color: subjectColor.opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: isActive ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Reset or Skip
                    Button(action: {
                        withAnimation {
                            timeElapsed = 0
                            isActive = false
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 64, height: 64)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { _ in
            if isActive && timeElapsed < sessionDuration {
                timeElapsed += 1
                if isActive {
                    pulseAmount = 1.2
                }
            } else if timeElapsed >= sessionDuration {
                isActive = false
                showSummary = true
            }
        }
        .sheet(isPresented: $showSummary) {
            SessionSummaryView(subject: currentSubject, duration: timeElapsed)
                .environmentObject(data)
                .environmentObject(router)
        }
        .sheet(isPresented: $showHistory) {
            StudyHistoryView()
                .environmentObject(data)
        }
        .navigationBarHidden(true)
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func emoji(for subjectName: String) -> String {
        switch subjectName.lowercased() {
        case "english": return "📚"
        case "science": return "🔬"
        case "ict": return "💻"
        case "maths", "math": return "➕"
        default: return "📖"
        }
    }
}
