import SwiftUI

struct InAppAlertView: View {
    let alert: AppAlert
    let dismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(alert.color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: alert.icon)
                    .foregroundColor(alert.color)
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(alert.message)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(alert.color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
