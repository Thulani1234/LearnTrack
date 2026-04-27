import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var agreedToTerms = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Join LearnTrack and start tracking your academic success today.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $fullName)
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    CustomTextField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                }
                .padding(.top, 10)
                
                // Terms & Conditions
                Toggle(isOn: $agreedToTerms) {
                    HStack(spacing: 4) {
                        Text("I agree to the")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Terms of Service")
                            .font(AppTypography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        Text("&")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Privacy Policy")
                            .font(AppTypography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.top, 10)
                
                // Sign Up Button
                Button(action: {
                    signUp()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
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
                .disabled(isLoading || !agreedToTerms || fullName.isEmpty || email.isEmpty || password.isEmpty || password != confirmPassword)
                .padding(.top, 10)
                
                Spacer()
                
                // Footer
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("Already have an account?")
                            .font(AppTypography.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Sign In")
                            .font(AppTypography.bodySmall)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.textPrimary)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private func signUp() {
        isLoading = true
        // Simulate sign up delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation {
                appState.isLoggedIn = true
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? AppColors.primary : AppColors.textSecondary)
                    .font(.system(size: 20))
                
                configuration.label
            }
        }
    }
}
