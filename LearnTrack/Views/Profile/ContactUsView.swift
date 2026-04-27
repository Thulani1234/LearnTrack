import SwiftUI

struct ContactUsView: View {
    @EnvironmentObject var router: AppRouter
    @State private var message = ""
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
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
                    Text("Contact Us")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Rectangle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Support Hero
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "envelope.badge.shield.half.filled")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.primary)
                            }
                            
                            Text("We'd love to hear from you")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Contact Methods
                        HStack(spacing: 16) {
                            ContactMethodCard(title: "Email", subtitle: "support@learn.com", icon: "envelope.fill", color: .blue)
                            ContactMethodCard(title: "Chat", subtitle: "Live Support", icon: "bubble.left.and.bubble.right.fill", color: .green)
                        }
                        .padding(.horizontal)
                        
                        // Contact Form
                        VStack(alignment: .leading, spacing: 24) {
                            Text("SEND A MESSAGE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            VStack(spacing: 20) {
                                CustomInputField(title: "YOUR EMAIL", placeholder: "alex@example.com", text: $email)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("MESSAGE")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                    
                                    TextEditor(text: $message)
                                        .frame(height: 120)
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation { showSuccess = true }
                        }) {
                            Text("Send Message")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(20)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            
            if showSuccess {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { showSuccess = false }
                
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        Text("Message Sent!")
                            .font(.system(size: 20, weight: .bold))
                        Text("Our team will get back to you within 24 hours.")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Close") { showSuccess = false }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                .padding(32)
                .background(AppColors.cardBackground)
                .cornerRadius(32)
                .shadow(radius: 20)
                .padding(40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ContactMethodCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}
