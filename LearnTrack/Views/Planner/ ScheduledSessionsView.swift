//
//   ScheduledSessionsView..swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ScheduledSessionsView: View {
    var date: Date
    let sessions = MockData.shared.scheduledSessions
    
    private var dailySessions: [StudySession] {
        sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessions for \\(date.formatted(.dateTime.month().day()))")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal)
            
            if dailySessions.isEmpty {
                Text("No sessions planned.")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
            } else {
                ForEach(dailySessions) { session in
                    SessionCard(session: session)
                        .padding(.horizontal)
                }
            }
        }
    }
}

