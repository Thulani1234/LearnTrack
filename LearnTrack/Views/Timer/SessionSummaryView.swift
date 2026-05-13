import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @Environment(\.dismiss) var dismiss
    
    var subject: Subject
    var totalTime: Int
    var isCompleted: Bool
    var progressGain: Int? = nil
    
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
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 4) {
                            Text("Session Concluded")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("The session for \(subject.name) has ended.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Stats
                    HStack(spacing: 16) {
                        SummaryCard(title: "Duration", value: timeString(totalTime), icon: "timer", color: .blue)
                        SummaryCard(title: "Efficiency", value: "\(calculateEfficiency())%", icon: "bolt.fill", color: .green)
                    }
                    .padding(.horizontal)
                    .offset(y: -20)
                    
                    
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
                            ActionRow(title: "Record Voice Summary", icon: "mic.fill", color: .blue) {
                                dismiss()
                                router.navigate(to: .voiceNotes)
                            }
                            Divider().padding(.leading, 60)
                            ActionRow(title: "Save to Calendar", icon: "calendar.badge.plus", color: .green) {
                                Task {
                                    await CalendarManager.shared.addStudySession(
                                        title: subject.name,
                                        startDate: Date().addingTimeInterval(-TimeInterval(totalTime)),
                                        endDate: Date(),
                                        notes: "Study session completed in LearnTrack."
                                    )
                                }
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
        .onAppear {
            data.addStudySession(subjectId: subject.id, durationSeconds: totalTime)
        }
    }
    
    func timeString(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func calculateEfficiency() -> Int {
        let minutes = totalTime / 60
        if minutes < 1 {
            return 40
        } else if minutes < 5 {
            return 50 + (minutes * 5)
        } else if minutes < 30 {
            return 70 + ((minutes - 5) / 5)
        } else {
            return min(95, 80 + ((minutes - 30) / 10))
        }
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


