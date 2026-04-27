import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @Environment(\.dismiss) var dismiss
    
    var subject: Subject
    var duration: Int
    var quizScore: Int? = nil
    var progressGain: Int? = nil
    
    @State private var isSummarizing = false
    @State private var summaryText: String? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Celebration Header
                ZStack {
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                    
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 4) {
                            Text("Brilliant Work!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Session complete for \(subject.name)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Stats
                    HStack(spacing: 16) {
                        SummaryCard(title: "Duration", value: timeString(duration), icon: "timer", color: .blue)
                        SummaryCard(title: "Efficiency", value: "92%", icon: "bolt.fill", color: .green)
                    }
                    .padding(.horizontal)
                    .offset(y: -20)
                    
                    // Auto Summarize Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("AI SESSION INSIGHTS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            Spacer()
                            if summaryText == nil {
                                Button(action: autoSummarize) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                        Text("Auto Summarize")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        if isSummarizing {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .tint(AppColors.primary)
                                Text("AI is analyzing your study patterns...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                            }
                            .padding(20)
                            .background(AppColors.cardBackground)
                            .cornerRadius(24)
                        } else if let summary = summaryText {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(summary)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineSpacing(4)
                                
                                Divider()
                                
                                HStack {
                                    Label("Deep Focus", systemImage: "brain.head.profile.fill")
                                    Spacer()
                                    Label("Productive", systemImage: "chart.line.uptrend.xyaxis")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.primary)
                            }
                            .padding(20)
                            .background(AppColors.cardBackground)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NEXT STEPS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        VStack(spacing: 0) {
                            ActionRow(title: "Add Session Note", icon: "note.text", color: .orange) {
                                dismiss()
                                router.navigate(to: .addNote)
                            }
                            Divider().padding(.leading, 60)
                            ActionRow(title: "Take Performance Quiz", icon: "pencil.and.outline", color: .purple) {
                                dismiss()
                                router.navigate(to: .quizList)
                            }
                            Divider().padding(.leading, 60)
                            ActionRow(title: "Record Voice Summary", icon: "mic.fill", color: .blue) {
                                dismiss()
                                router.navigate(to: .voiceNotes)
                            }
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // Done Button
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppColors.primary)
                            .cornerRadius(24)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private func autoSummarize() {
        isSummarizing = true
        // Simulate AI generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isSummarizing = false
                summaryText = "During this \(subject.name) session, you maintained a high focus level for 85% of the time. You successfully covered the core concepts and showed strong retention in the interactive segments. Great job staying on track!"
            }
        }
    }
    
    func timeString(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.3))
            }
            .padding(12)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
