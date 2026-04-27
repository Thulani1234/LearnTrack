import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                // Animated background blobs for premium feel
                VStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 50)
                        .offset(x: -150, y: -100)
                    Spacer()
                    Circle()
                        .fill(AppColors.secondary.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 50)
                        .offset(x: 150, y: 100)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Identity
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("LearnTrack")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Your Journey to Excellence")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textSecondary.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Features Summary
                    VStack(alignment: .leading, spacing: 16) {
                        WelcomeFeatureRow(icon: "bolt.fill", title: "Smart Tracking", subtitle: "Real-time study timer and results analysis.")
                        WelcomeFeatureRow(icon: "target", title: "Target Goals", subtitle: "Set academic targets and monitor your gap.")
                        WelcomeFeatureRow(icon: "shield.fill", title: "Secure Data", subtitle: "Your progress is synced and safe.")
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Get Started")
                                .font(AppTypography.body)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(18)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: {
                            showLogin = true
                        }) {
                            Text("I already have an account")
                                .font(AppTypography.body)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

struct WelcomeFeatureRow: View {
    var icon: String
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primary)
                .frame(width: 44, height: 44)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}
