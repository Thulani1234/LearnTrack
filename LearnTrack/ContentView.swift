//
//  ContentView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isFirstLaunch {
                OnboardingView()
            } else if !appState.isLoggedIn {
                WelcomeView()
            } else if appState.isLocked {
                FaceIDView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appState.isFirstLaunch)
        .animation(.easeInOut, value: appState.isLoggedIn)
        .animation(.easeInOut, value: appState.isLocked)
    }
}

