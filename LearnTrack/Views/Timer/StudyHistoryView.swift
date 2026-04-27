import SwiftUI

struct StudyHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: MockData
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Study History")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(10)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Overall Stats Card
                    HStack(spacing: 20) {
                        HistoryStatItem(label: "Total Sessions", value: "\(data.recentSessions.count)", icon: "book.fill", color: .blue)
                        Divider().frame(height: 40)
                        HistoryStatItem(label: "Focus Time", value: "12h", icon: "timer", color: .orange)
                        Divider().frame(height: 40)
                        HistoryStatItem(label: "Avg. Daily", value: "45m", icon: "chart.bar.fill", color: .green)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // History List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RECENT ACTIVITIES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            .padding(.horizontal)
                        
                        let completedSessions = data.recentSessions.filter { $0.isCompleted }.sorted(by: { $0.date > $1.date })
                        
                        if completedSessions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.3))
                                Text("No sessions recorded yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            ForEach(completedSessions) { session in
                                if let subject = data.subject(for: session.subjectId) {
                                    CreativeHistoryCard(session: session, subject: subject)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct HistoryStatItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CreativeHistoryCard: View {
    var session: StudySession
    var subject: Subject
    
    var body: some View {
        HStack(spacing: 16) {
            // Subject Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: subject.colorHex).opacity(0.1))
                    .frame(width: 54, height: 54)
                
                Text(emoji(for: subject.name))
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(session.date, style: .date)
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(session.durationSeconds))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: subject.colorHex))
                
                Text("Completed")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        return mins > 0 ? "\(mins)m" : "\(seconds)s"
    }
    
    private func emoji(for subjectName: String) -> String {
        switch subjectName.lowercased() {
        case "english": return "📚"
        case "science": return "🔬"
        case "ict": return "💻"
        case "maths", "math": return "➕"
        default: return "📖"
        }
    }
}
