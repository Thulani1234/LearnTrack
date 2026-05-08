import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State private var email            = ""
    @State private var currentPassword  = ""
    @State private var newPassword      = ""
    @State private var confirmPassword  = ""

    @State private var isLoading    = false
    @State private var showMessage  = false
    @State private var message      = ""
    @State private var isError      = false
    @State private var showSuccess  = false

    private let authService = AuthenticationService.shared

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Background decorative circle
            VStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary.opacity(0.08), AppColors.secondary.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 380, height: 380)
                    .offset(x: 120, y: -180)
                Spacer()
            }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 24)

                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                                .padding(14)
                                .background(AppColors.primary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            Spacer()
                        }

                        Text("Change Password")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 6)

                        Text("Enter your account email, current password, and choose a new password.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 28)

                    // Fields card
                    VStack(spacing: 16) {
                        // Email
                        fieldLabel("Email Address")
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email Address",
                            text: $email,
                            disableAutocapitalization: true
                        )

                        Divider()
                            .background(AppColors.textSecondary.opacity(0.15))
                            .padding(.vertical, 2)

                        // Current Password
                        fieldLabel("Current Password")
                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "Current Password",
                            text: $currentPassword,
                            isSecure: true
                        )

                        // New Password
                        fieldLabel("New Password")
                        CustomTextField(
                            icon: "lock.open.fill",
                            placeholder: "New Password",
                            text: $newPassword,
                            isSecure: true
                        )

                        // Confirm New Password
                        fieldLabel("Confirm New Password")
                        CustomTextField(
                            icon: "checkmark.shield.fill",
                            placeholder: "Confirm New Password",
                            text: $confirmPassword,
                            isSecure: true
                        )

                        // Password strength hint
                        if !newPassword.isEmpty {
                            strengthIndicator(for: newPassword)
                        }
                    }
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    // Feedback message
                    if showMessage {
                        HStack(spacing: 10) {
                            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                                .foregroundColor(isError ? .red : AppColors.primary)
                            Text(message)
                                .font(AppTypography.bodySmall)
                                .foregroundColor(isError ? .red : AppColors.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Update Password button
                    Button(action: changePassword) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Update Password")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            isFormValid
                                ? AppColors.primary
                                : AppColors.primary.opacity(0.4)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(isFormValid ? 0.3 : 0), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || !isFormValid)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.2), value: isFormValid)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.25), value: showMessage)
        .alert("Password Updated", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your password has been changed successfully. Please log in with your new password.")
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !currentPassword.isEmpty
            && newPassword.count >= 6
            && newPassword == confirmPassword
    }

    @ViewBuilder
    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func strengthIndicator(for pwd: String) -> some View {
        let strength = passwordStrength(pwd)
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index < strength.score ? strength.color : AppColors.textSecondary.opacity(0.2))
                    .frame(height: 4)
            }
            Text(strength.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(strength.color)
        }
    }

    private func passwordStrength(_ pwd: String) -> (score: Int, label: String, color: Color) {
        var score = 0
        if pwd.count >= 8 { score += 1 }
        if pwd.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if pwd.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if pwd.rangeOfCharacter(from: .punctuationCharacters) != nil || pwd.rangeOfCharacter(from: .symbols) != nil { score += 1 }

        switch score {
        case 0, 1: return (max(score, 1), "Weak",   .red)
        case 2:    return (2,             "Fair",   .orange)
        case 3:    return (3,             "Good",   Color(hue: 0.22, saturation: 0.9, brightness: 0.85))
        default:   return (4,             "Strong", AppColors.primary)
        }
    }

    // MARK: - Action

    private func changePassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            showFeedback("Please enter your email address.", isError: true); return
        }
        guard !currentPassword.isEmpty else {
            showFeedback("Please enter your current password.", isError: true); return
        }
        guard newPassword.count >= 6 else {
            showFeedback("New password must be at least 6 characters.", isError: true); return
        }
        guard newPassword == confirmPassword else {
            showFeedback("New password and confirmation do not match.", isError: true); return
        }
        guard newPassword != currentPassword else {
            showFeedback("New password must be different from the current password.", isError: true); return
        }

        isLoading = true
        showMessage = false

        let success = authService.changePassword(
            email: trimmedEmail,
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
            if success {
                showSuccess = true
            } else {
                showFeedback("Incorrect email or current password. Please try again.", isError: true)
            }
        }
    }

    private func showFeedback(_ msg: String, isError: Bool) {
        message         = msg
        self.isError    = isError
        showMessage     = true
    }
}
