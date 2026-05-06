import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showMessage = false
    @State private var message = ""
    @State private var isError = false
    
    private let authService = AuthenticationService.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reset Password")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Enter your email address and we will send instructions to reset your password.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 30)
                
                CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email, disableAutocapitalization: true)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    resetPassword()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading || email.isEmpty)
                .padding(.horizontal, 30)
                
                if showMessage {
                    Text(message)
                        .font(AppTypography.bodySmall)
                        .foregroundColor(isError ? .red : AppColors.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func resetPassword() {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showMessage = true
            message = "Please enter your email address."
            isError = true
            return
        }
        
        isLoading = true
        showMessage = false
        let _ = authService.generateOTPForEmail(email: email)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoading = false
            showMessage = true
            isError = false
            message = "If an account exists for this email, a reset link has been sent. Check your inbox."
        }
    }
}
