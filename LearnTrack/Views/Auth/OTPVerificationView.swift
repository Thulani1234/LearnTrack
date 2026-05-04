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
    
    let userPhone: String
    let onSuccess: () -> Void
    
    init(userPhone: String, onSuccess: @escaping () -> Void) {
        self.userPhone = userPhone
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
                            
                            Image(systemName: "phone.badge.plus")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Verify Your Phone")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("We've sent a 6-digit verification code to")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text(userPhone)
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
        
        // Simulate OTP verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // For demo: accept "123456" as valid OTP
            let enteredCode = otpCode.joined()
            if enteredCode == "123456" {
                onSuccess()
            } else {
                showError = true
                errorMessage = "Invalid verification code. Please try again."
                
                // Clear OTP fields
                otpCode = Array(repeating: "", count: 6)
            }
        }
    }
    
    private func resendOTP() {
        timeRemaining = 60
        canResend = false
        startTimer()
        
        // Simulate sending OTP
        print("OTP resent to: \(userPhone)")
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? AppColors.primary.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                )
                .frame(width: 50, height: 60)
            
            Text(digit)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
        .onTapGesture {
            // Handle tap to focus (simplified for demo)
        }
    }
}

// MARK: - Preview
struct OTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationView(userPhone: "+1234567890") {
            print("OTP verified successfully")
        }
        .preferredColorScheme(.light)
    }
}
