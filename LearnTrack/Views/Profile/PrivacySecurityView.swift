import SwiftUI

struct PrivacySecurityView: View {
    @EnvironmentObject var router: AppRouter
    @State private var faceIDEnabled = true
    @State private var dataSyncEnabled = true
    @State private var analyticsEnabled = false
    @State private var twoFactorEnabled = true
    
    var body: some View {
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
                Text("Privacy & Security")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Security Shield Icon
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 100, height: 100)
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 44))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Protection Section
                        SecuritySection(title: "PROTECTION") {
                            SecurityToggle(title: "Face ID Authentication", subtitle: "Secure your study data with biometrics", icon: "faceid", color: .blue, isOn: $faceIDEnabled)
                            Divider().padding(.leading, 50)
                            SecurityToggle(title: "Two-Factor Auth", subtitle: "Extra layer for account security", icon: "key.fill", color: .orange, isOn: $twoFactorEnabled)
                        }
                        
                        // Data & Privacy Section
                        SecuritySection(title: "DATA & PRIVACY") {
                            SecurityToggle(title: "Cloud Sync", subtitle: "Backup your progress across devices", icon: "icloud.fill", color: .blue, isOn: $dataSyncEnabled)
                            Divider().padding(.leading, 50)
                            SecurityToggle(title: "Share Analytics", subtitle: "Help us improve LearnTrack", icon: "chart.bar.fill", color: .purple, isOn: $analyticsEnabled)
                        }
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADVANCED")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            Button(action: {}) {
                                HStack {
                                    Text("Clear All Study History")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.05))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SecuritySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            
            VStack(spacing: 0) {
                content
            }
            .background(AppColors.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        }
    }
}

struct SecurityToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColors.primary)
        }
        .padding()
    }
}
