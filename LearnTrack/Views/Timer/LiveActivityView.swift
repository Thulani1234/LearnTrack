//
//  LiveActivityView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

// This is a UI mockup of how the Live Activity would look.
// In a real app, this would be an Activity Widget extension.

struct LiveActivityView: View {
    var subjectName = "Mathematics"
    var timeRemaining = "00:12:34"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(AppColors.primary)
                Text("LearnTrack")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text(timeRemaining)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            Text("Studying \\(subjectName)")
                .font(.footnote)
                .foregroundColor(.gray)
            
            ProgressBar(progress: 0.6, color: AppColors.primary)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(24)
        .shadow(radius: 10)
        .padding()
    }
}
