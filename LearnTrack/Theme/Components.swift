//
//  Components..swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppTypography.body)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [AppColors.primary, AppColors.secondary]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
            .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}

struct ProgressBar: View {
    var progress: Double
    var color: Color = AppColors.primary
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(color)
                    .animation(.spring(), value: progress)
            }
            .cornerRadius(4)
        }
        .frame(height: 8)
    }
}
