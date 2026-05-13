import SwiftUI

struct LiveView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
    @State private var sessionCode = ""
    @State private var showingCreateSheet = false
    
    var body: some View {
        ZStack {
            // Creative Background
            AppColors.background.ignoresSafeArea()
            
            // Animated Background Glows
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(AppColors.secondary.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 150, y: 300)
                
                // Floating Emojis
                Text("").font(.system(size: 40)).opacity(0.1).offset(x: -100, y: 100)
                Text("").font(.system(size: 30)).opacity(0.1).offset(x: 120, y: -50)
                Text("").font(.system(size: 35)).opacity(0.1).offset(x: -80, y: -300)
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Live Study Sessions")
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            

                        }
                        Spacer()
                        
                        Button(action: { /* Profile action - removed */ }) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.cardBackground)
                                    .frame(width: 54, height: 54)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                Image(systemName: "person.2.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    

                    
                    // Premium Start a Session Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create a Private Study Room")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Establish a private academic focus environment and facilitate collaborative study sessions with users.")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(4)
                            }
                            Spacer()
                        }
                        
                        Button(action: { showingCreateSheet = true }) {
                            HStack {
                                Text("Start Session")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .background(AppColors.primary)
                            .cornerRadius(20)
                            .shadow(color: AppColors.primary.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(32)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "F0F9FF"), Color(hex: "E0F2FE")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Circle()
                                .fill(AppColors.primary.opacity(0.05))
                                .frame(width: 300, height: 300)
                                .offset(x: 120, y: -100)
                                .blur(radius: 40)
                        }
                    )
                    .cornerRadius(32)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 15)
                    .padding(.horizontal)
                    
                    
                    // Join with Code Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("JOIN A PRIVATE ROOM")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary.opacity(0.4))
                            .tracking(2)
                            .padding(.horizontal, 8)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 15) {
                                TextField("Enter 6-digit code...", text: $sessionCode)
                                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            }
                            .padding(24)
                            .background(AppColors.cardBackground)
                            .cornerRadius(24, corners: [.topLeft, .topRight])
                            
                            Button(action: {
                                if !sessionCode.isEmpty {
                                    triggerJoinAnimation(roomName: "Private Room")
                                }
                            }) {
                                HStack {
                                    Text("Join Session")
                                        .font(.system(size: 16, weight: .bold))
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(AppColors.primary)
                                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(isPresented: $showingCreateSheet) {
            CreateSessionView()
                .environmentObject(appState)
                .environmentObject(data)
        }
    }
    
    func triggerJoinAnimation(roomName: String = "Live Room") {
        withAnimation {
            appState.joiningRoomName = roomName
            appState.isJoiningRoom = true
        }
    }
}

struct TrendingTag: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(AppTypography.bodySmall)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CreateSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
    @State private var roomName = ""
    @State private var selectedSubjectId: UUID?
    @State private var sessionCode = ""
    @State private var animateItems = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Start Focus Room")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(24)
                .offset(y: animateItems ? 0 : -20)
                .opacity(animateItems ? 1 : 0)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("WHAT'S THE GOAL?")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            TextField("e.g. Physics Final Revision ", text: $roomName)
                                .font(.system(size: 18, weight: .medium))
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(AppColors.cardBackground)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CHOOSE YOUR SUBJECT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(data.subjects) { subject in
                                    SubjectSelectionCard(
                                        subject: subject,
                                        isSelected: selectedSubjectId == subject.id
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedSubjectId = subject.id
                                            sessionCode = "LT-\(Int.random(in: 1000...9999))"
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !sessionCode.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("YOUR SESSION CODE")
                                    .font(.system(size: 12, weight: .bold))
                                HStack {
                                    Text(sessionCode)
                                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppColors.primary)
                                    Spacer()
                                    Button(action: {
                                        UIPasteboard.general.string = sessionCode
                                        appState.currentAlert = AppAlert(title: "Copied!", message: "Code copied to clipboard", icon: "doc.on.doc", color: AppColors.primary, type: .success)
                                    }) {
                                        Text("Copy").bold()
                                            .padding(.horizontal, 16).padding(.vertical, 8)
                                            .background(AppColors.primary.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(20).background(AppColors.cardBackground).cornerRadius(20)
                            }
                        }
                    }
                    .padding(24)
                }
                
                Button(action: { dismiss() }) {
                    Text("Launch Room")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding().background(AppColors.primary).cornerRadius(20)
                }
                .padding(24)
                .disabled(selectedSubjectId == nil)
            }
        }
        .onAppear { withAnimation { animateItems = true } }
    }
}

struct SubjectSelectionCard: View {
    let subject: Subject
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: subject.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(hex: subject.colorHex) : AppColors.textPrimary)
                Text(subject.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: subject.colorHex).opacity(0.2) : AppColors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: subject.colorHex) : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: style)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

