//
//  MainTabView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var router = AppRouter()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.cardBackground)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)
        UITabBar.appearance().tintColor = UIColor(AppColors.primary)
    }
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $router.path) {
                DashboardView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack(path: $router.path) {
                PlannerView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Planner", systemImage: "calendar")
            }
            .tag(1)
            
            NavigationStack(path: $router.path) {
                SubjectsView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Subjects", systemImage: "books.vertical.fill")
            }
            .tag(2)
            
            NavigationStack(path: $router.path) {
                ReportView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Reports", systemImage: "chart.bar.fill")
            }
            .tag(3)
            
            NavigationStack(path: $router.path) {
                ProfileView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(4)
        }
        .accentColor(AppColors.primary)
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .dashboard:
            DashboardView()
                .environmentObject(router)
        case .planner:
            PlannerView()
                .environmentObject(router)
        case .planSession:
            PlanASessionView()
                .environmentObject(router)
        case .subjects:
            SubjectsView()
                .environmentObject(router)
        case .addSubject:
            AddSubjectView()
                .environmentObject(router)
        case .timer(let subject):
            StudyTimerView(subject: subject)
                .environmentObject(router)
        case .quizList:
            QuizListView()
                .environmentObject(router)
        case .quiz(let quiz):
            QuizView(quiz: quiz)
                .environmentObject(router)
        case .results:
            ResultsView()
                .environmentObject(router)
        case .addResult:
            AddResultView()
                .environmentObject(router)
        case .targetActual:
            TargetActualView()
                .environmentObject(router)
        case .voiceNotes:
            VoiceNotesView()
                .environmentObject(router)
        case .report:
            ReportView()
                .environmentObject(router)
        case .profile:
            ProfileView()
                .environmentObject(router)
        case .settings:
            SettingsView()
                .environmentObject(router)
        case .notifications:
            NotificationsView()
                .environmentObject(router)
        case .planSetup:
            PlanSetupView()
                .environmentObject(router)
        case .planGenerated:
            PlanGeneratedView()
                .environmentObject(router)
        }
    }
}

