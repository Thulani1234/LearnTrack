import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Background Decorative Elements
            VStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColors.primary.opacity(0.1), AppColors.secondary.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 400, height: 400)
                    .offset(x: 100, y: -200)
                Spacer()
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Welcome
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                        .padding()
                        .background(AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Sign in to continue your learning journey")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Input Fields
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    
                    Button(action: {
                        // Forgot password action
                    }) {
                        Text("Forgot Password?")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.top, 20)
                
                // Login Button
                Button(action: {
                    login()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                    Text("OR")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                }
                
                // Social login placeholders (Premium feel)
                HStack(spacing: 20) {
                    SocialButton(icon: "apple.logo")
                    SocialButton(icon: "google.logo", isSystem: false) // Google logo would be an image in real app
                }
                
                Spacer()
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Sign Up")
                            .font(AppTypography.bodySmall)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
    }
    
    private func login() {
        isLoading = true
        // Simulate login delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation {
                appState.isLoggedIn = true
            }
        }
    }
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary.opacity(0.7))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SocialButton: View {
    var icon: String
    var isSystem: Bool = true
    
    var body: some View {
        Button(action: {}) {
            if isSystem {
                Image(systemName: icon)
                    .font(.title3)
            } else {
                // Placeholder for custom image
                Text("G")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .frame(width: 60, height: 60)
        .background(AppColors.cardBackground)
        .foregroundColor(AppColors.textPrimary)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}
