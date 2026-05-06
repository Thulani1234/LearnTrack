//
//  OTPVerificationView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct OTPVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer?
    @State private var canResend = false
    
    let userEmail: String
    let onSuccess: () -> Void
    
    private let authService = AuthenticationService.shared
    
    init(userEmail: String, onSuccess: @escaping () -> Void) {
        self.userEmail = userEmail
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 20) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Verify Your Email")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("We've sent a 6-digit verification code to")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text(userEmail)
                                .font(AppTypography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // OTP Input Fields
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                OTPDigitField(
                                    digit: $otpCode[index],
                                    isActive: otpCode[index].isEmpty && index == 0 || 
                                             !otpCode[index-1].isEmpty && index > 0 && index == otpCode.filter({ !$0.isEmpty }).count
                                )
                                .onChange(of: otpCode[index]) { newValue in
                                    handleOTPChange(index: index, value: newValue)
                                }
                            }
                        }
                        
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                
                                Text(errorMessage)
                                    .font(AppTypography.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Verify Button
                    Button(action: {
                        verifyOTP()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Verify Code")
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
                    .disabled(isLoading || !isOTPComplete())
                    .padding(.horizontal, 30)
                    
                    // Resend Section
                    VStack(spacing: 16) {
                        if timeRemaining > 0 {
                            VStack(spacing: 8) {
                                Text("Resend code in")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                        } else {
                            Button(action: {
                                resendOTP()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Resend Verification Code")
                                        .font(AppTypography.body)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primary, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Footer
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Back to Sign Up")
                                .font(AppTypography.bodySmall)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 30)
                }
            }
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
        .onAppear {
            startTimer()
            // Send OTP when view appears
            let otp = authService.generateOTPForEmail(email: userEmail)
            print("OTP sent to \(userEmail): \(otp)")
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func isOTPComplete() -> Bool {
        return otpCode.allSatisfy { !$0.isEmpty }
    }
    
    private func handleOTPChange(index: Int, value: String) {
        // Only allow single digit
        if value.count > 1 {
            otpCode[index] = String(value.prefix(1))
            return
        }
        
        // Auto-advance to next field
        if !value.isEmpty && index < 5 {
            // Focus next field (handled by isActive state)
        }
        
        // Auto-submit when complete
        if isOTPComplete() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                verifyOTP()
            }
        }
    }
    
    private func verifyOTP() {
        guard isOTPComplete() else { return }
        
        isLoading = true
        showError = false
        
        let otpString = otpCode.joined()
        
        // Verify OTP using authentication service
        let isValid = authService.validateOTP(otp: otpString, phoneNumber: userEmail)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            if isValid {
                // Verify user email
                let emailVerified = self.authService.verifyUserEmail(email: self.userEmail)
                
                if emailVerified {
                    print("OTP verified successfully for \(self.userEmail)")
                    self.onSuccess()
                } else {
                    self.showError = true
                    self.errorMessage = "Failed to verify email. Please try again."
                }
            } else {
                self.showError = true
                self.errorMessage = "Invalid OTP code. Please try again."
            }
        }
    }
    
    private func resendOTP() {
        timeRemaining = 60
        canResend = false
        startTimer()
        
        // Generate new OTP
        let newOTP = authService.generateOTPForEmail(email: userEmail)
        print("New OTP sent to \(userEmail) - \(newOTP)")
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
                timer?.invalidate()
            }
        }
    }
}

struct OTPDigitField: View {
    @Binding var digit: String
    let isActive: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? AppColors.primary.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                )
                .frame(width: 50, height: 60)
            
            TextField("", text: $digit)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .onChange(of: digit) { newValue in
                    // Only allow single digit
                    if newValue.count > 1 {
                        digit = String(newValue.prefix(1))
                    }
                    // Only allow numbers
                    if !newValue.isEmpty && !newValue.allSatisfy({ $0.isNumber }) {
                        digit = ""
                    }
                }
                .onAppear {
                    if isActive {
                        isFocused = true
                    }
                }
                .onChange(of: isActive) { newValue in
                    if newValue {
                        isFocused = true
                    }
                }
        }
    }
}

// MARK: - Preview
struct OTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationView(userEmail: "user@example.com") {
            print("OTP verified successfully")
        }
        .preferredColorScheme(.light)
    }
}
