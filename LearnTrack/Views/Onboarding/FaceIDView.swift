//
//  FaceIDView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct FaceIDView: View {
    @EnvironmentObject var appState: AppState
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "faceid")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(AppColors.primary)
            
            Text("App Locked")
                .font(AppTypography.titleLarge)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Please authenticate to access your learning data.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.error)
            }
            
            Spacer()
            
            PrimaryButton(title: "Unlock with Face ID", icon: "faceid") {
                authenticate()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        FaceIDManager.shared.authenticate { success, error in
            if success {
                withAnimation {
                    appState.unlock()
                }
            } else {
                errorMessage = error
            }
        }
    }
}
