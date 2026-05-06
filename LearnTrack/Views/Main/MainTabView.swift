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
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch appState.selectedTab {
                case 0:
                    NavigationStack(path: $router.path) {
                        DashboardView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                case 1:
                    NavigationStack(path: $router.path) {
                        PlannerView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                case 2:
                    NavigationStack(path: $router.path) {
                        LiveView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                case 3:
                    NavigationStack(path: $router.path) {
                        SubjectsView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                case 4:
                    NavigationStack(path: $router.path) {
                        ReportView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                case 5:
                    NavigationStack(path: $router.path) {
                        ProfileView()
                            .environmentObject(router)
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                default:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 90) // Space for custom tab bar
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarItem(icon: "house.fill", label: "Home", isSelected: appState.selectedTab == 0) {
                    selectTab(0)
                }
                TabBarItem(icon: "calendar", label: "Plan", isSelected: appState.selectedTab == 1) {
                    selectTab(1)
                }
                TabBarItem(icon: "person.2.fill", label: "Live", isSelected: appState.selectedTab == 2) {
                    selectTab(2)
                }
                TabBarItem(icon: "books.vertical.fill", label: "Subjects", isSelected: appState.selectedTab == 3) {
                    selectTab(3)
                }
                TabBarItem(icon: "chart.bar.fill", label: "Report", isSelected: appState.selectedTab == 4) {
                    selectTab(4)
                }
                TabBarItem(icon: "person.crop.circle.fill", label: "Profile", isSelected: appState.selectedTab == 5) {
                    selectTab(5)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 34)
            .background(
                AppColors.cardBackground
                    .ignoresSafeArea()
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -5)
            )
        }
        .accentColor(AppColors.primary)
        .environmentObject(router)
        .overlay(alignment: .center) {
            if appState.isJoiningRoom {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    VStack(spacing: 32) {
                        // Creative Pulse Animation
                        ZStack {
                            Circle()
                                .stroke(AppColors.primary.opacity(0.3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                                .scaleEffect(appState.isJoiningRoom ? 1.5 : 1.0)
                                .opacity(appState.isJoiningRoom ? 0 : 0.5)
                                .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: appState.isJoiningRoom)
                            
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 60, height: 60)
                                .shadow(color: AppColors.primary.opacity(0.5), radius: 20)
                            
                            Image(systemName: "video.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Joining Room")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(appState.joiningRoomName)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        HStack(spacing: 12) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("Establishing secure connection...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(48)
                    .background(
                        BlurView(style: .systemThinMaterialDark)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .cornerRadius(40)
                    .shadow(color: Color.black.opacity(0.3), radius: 30)
                }
                .transition(.asymmetric(insertion: .opacity, removal: .scale.combined(with: .opacity)))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            let room = appState.joiningRoomName
                            appState.isJoiningRoom = false
                            router.navigate(to: .meetingRoom(room))
                        }
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if let alert = appState.currentAlert {
                InAppAlertView(alert: alert) {
                    withAnimation(.spring()) {
                        appState.currentAlert = nil
                    }
                }
                .transition(AnyTransition.move(edge: Edge.top).combined(with: AnyTransition.opacity))
                .zIndex(100)
            }
        }
    }
    
    private func selectTab(_ tab: Int) {
        if appState.selectedTab != tab {
            router.navigateToRoot()
        }
        appState.selectedTab = tab
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
        case .results:
            ResultsView()
                .environmentObject(router)
        case .addResult:
            AddResultView()
                .environmentObject(router)
                .environmentObject(appState)
        case .targetActual:
            TargetActualView()
                .environmentObject(router)
        case .voiceNotes:
            VoiceNotesView()
                .environmentObject(router)
        case .notes:
            NotesView()
                .environmentObject(router)
        case .addNote:
            AddNoteView()
                .environmentObject(router)
        case .report:
            ReportView()
                .environmentObject(router)
        case .profile:
            ProfileView()
                .environmentObject(router)
        case .editProfile:
            EditProfileView()
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
        case .privacy:
            PrivacySecurityView()
                .environmentObject(router)
        case .help:
            HelpCenterView()
                .environmentObject(router)
        case .contact:
            ContactUsView()
                .environmentObject(router)
        case .resultDetail(let result):
            SubjectResultsDetailView(result: result)
                .environmentObject(router)
        case .meetingRoom(let roomName):
            MeetingRoomView(roomName: roomName)
                .environmentObject(router)
        case .fullCalendar:
            FullCalendarView()
                .environmentObject(router)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
