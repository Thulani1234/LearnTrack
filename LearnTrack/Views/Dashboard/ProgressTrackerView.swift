//
//  ProgressTrackerView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ProgressTrackerView: View {
    var subjects: [Subject]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Progress")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 16) {
                ForEach(subjects.prefix(3)) { subject in
                    HStack {
                        Text(subject.name)
                            .font(AppTypography.bodySmall)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 80, alignment: .leading)
                        
                        ProgressBar(progress: subject.progress, color: Color(hex: subject.colorHex))
                        
                        Text("\\(Int(subject.progress * 100))%")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .cardStyle()
    }
}
