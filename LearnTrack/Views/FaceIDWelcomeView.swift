//
//  FaceIDWelcomeView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI
import LocalAuthentication

struct FaceIDWelcomeView: View {
    @State private var isAuthenticated = false
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var glowIntensity: Double = 0.3
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPressed: Bool = false
    @State private var waveOffset: CGFloat = 0
    
    let faceIDManager = FaceIDManager()
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles background
            ZStack {
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(0.03))
                        .frame(width: CGFloat.random(in: 2...6))
                        .position(
                            x: CGFloat.random(in: 0...400),
                            y: CGFloat.random(in: 0...800)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...8))
                            .repeatForever(autoreverses: true),
                            value: rotationAngle
                        )
                }
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Welcome message with animation
                VStack(spacing: 16) {
                    Text("Welcome to")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .scaleEffect(scaleEffect)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: scaleEffect)
                    
                    Text("LearnTrack")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    .white.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(scaleEffect)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: scaleEffect)
                    
                    Text("Your Personal Learning Companion")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .scaleEffect(scaleEffect)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: scaleEffect)
                }
                
                Spacer()
                
                // Enhanced Creative Face ID icon
                ZStack {
                    // Outer wave rings
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.1),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 200 + CGFloat(index * 50), height: 200 + CGFloat(index * 50))
                            .scaleEffect(1.0 + sin(waveOffset + Double(index) * 0.5) * 0.1)
                            .rotationEffect(.degrees(-rotationAngle * 0.3 + Double(index * 90)))
                            .animation(.easeInOut(duration: 3.0 + Double(index) * 0.5).repeatForever(autoreverses: true), value: waveOffset)
                    }
                    
                    // Orbiting rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                            .frame(width: 160 + CGFloat(index * 35), height: 160 + CGFloat(index * 35))
                            .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                            .animation(.linear(duration: 15 + Double(index * 7)).repeatForever(autoreverses: false), value: rotationAngle)
                    }
                    
                    // Central face ID button with enhanced effects
                    Button(action: {
                        authenticateWithFaceID()
                    }) {
                        ZStack {
                            // Multi-layered glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white.opacity(glowIntensity * 0.8),
                                            .white.opacity(glowIntensity * 0.4),
                                            .white.opacity(glowIntensity * 0.2),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 180, height: 180)
                                .scaleEffect(pulseScale)
                            
                            // Animated ripple effect
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .center,
                                        endPoint: .leading
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(1.0 + sin(rotationAngle * 0.05) * 0.2)
                                .rotationEffect(.degrees(-rotationAngle * 0.5))
                            
                            // Main interactive circle
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.15),
                                            .white.opacity(0.08),
                                            .white.opacity(0.12)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.5),
                                                    .white.opacity(0.3),
                                                    .white.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(isPressed ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                            
                            // Inner decorative ring
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(rotationAngle))
                            
                            // Enhanced Face ID icon
                            VStack(spacing: 6) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .white,
                                                .white.opacity(0.9)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaleEffect(1.0 + sin(rotationAngle * 0.02) * 0.1)
                                
                                Text("Face ID")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .tracking(1.2)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        isPressed = pressing
                        if pressing {
                            withAnimation(.easeOut(duration: 0.2)) {
                                glowIntensity = 0.8
                                pulseScale = 1.1
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.3)) {
                                glowIntensity = 0.3
                                pulseScale = 1.0
                            }
                        }
                    }, perform: {})
                }
                
                Spacer()
                
                // Status message
                VStack(spacing: 16) {
                    if showSuccess {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            Text("Authentication Successful")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.green)
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    } else if showError {
                        HStack(spacing: 12) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    } else {
                        Text("Tap to authenticate with Face ID")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                // Alternative options
                VStack(spacing: 16) {
                    Button(action: {
                        // Handle alternative authentication
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "touchid")
                                .font(.system(size: 20))
                            Text("Use Touch ID")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: {
                        // Handle passcode
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 20))
                            Text("Use Passcode")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 1.0)) {
            scaleEffect = 1.0
        }
        
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360.0
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            waveOffset = .pi * 2
        }
    }
    
    private func authenticateWithFaceID() {
        isAnimating = true
        showError = false
        showSuccess = false
        
        // Enhanced visual feedback during authentication
        withAnimation(.easeInOut(duration: 0.3)) {
            glowIntensity = 1.0
            pulseScale = 1.2
        }
        
        faceIDManager.authenticate { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAnimating = false
                
                if success {
                    // Success animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showSuccess = true
                        glowIntensity = 1.0
                        pulseScale = 1.3
                    }
                    
                    // Navigate to main app after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onComplete()
                    }
                } else {
                    // Error animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showError = true
                        errorMessage = error ?? "Authentication failed"
                        glowIntensity = 0.1
                        pulseScale = 0.9
                    }
                    
                    // Reset after error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showError = false
                            glowIntensity = 0.3
                            pulseScale = 1.0
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct FaceIDWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        FaceIDWelcomeView {
            print("Welcome complete")
        }
        .preferredColorScheme(.dark)
    }
}
