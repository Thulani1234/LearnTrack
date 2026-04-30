import SwiftUI

struct LiveSession: Identifiable {
    let id = UUID()
    let title: String
    let host: String
    let activeMinutes: Int
    let participants: [String]
    let color: Color
}

struct LiveView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
    @State private var sessionCode = ""
    @State private var showingCreateSheet = false
    
    let activeSessions = [
        LiveSession(title: "Science Revision Group", host: "Ahmed", activeMinutes: 38, participants: ["A", "S", "R"], color: .red),
        LiveSession(title: "Maths Study Room", host: "Sara", activeMinutes: 12, participants: ["S", "M"], color: .orange),
        LiveSession(title: "History Discussion", host: "Mike", activeMinutes: 5, participants: ["M", "J", "K", "L"], color: .blue)
    ]
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Live Study")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 8) {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                Text("1,240 Students Online")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "person.2.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Start a Session Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start a Session")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Others can join your session")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Button(action: { showingCreateSheet = true }) {
                            VStack(spacing: 2) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Create")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(16)
                        }
                    }
                    .padding(24)
                    .background(LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(28)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                    .padding(.horizontal)
                    
                    // Join with Code Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("JOIN WITH CODE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            TextField("Enter session code...", text: $sessionCode)
                                .padding()
                                .frame(height: 64)
                                .background(AppColors.cardBackground)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
                                )
                            
                            Button(action: {
                                if !sessionCode.isEmpty {
                                    triggerJoinAnimation(roomName: "Private Room")
                                }
                            }) {
                                Text("Join")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 90, height: 64)
                                    .background(AppColors.primary)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Active Sessions List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ACTIVE FOCUS ROOMS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(activeSessions) { session in
                                GroupSessionCard(session: session) {
                                    triggerJoinAnimation(roomName: session.title)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Your Session Code Footer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your session code")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Text("LT-8294")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.primary)
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = "LT-8294"
                                withAnimation {
                                    appState.currentAlert = AppAlert(
                                        title: "Code Copied! 📋",
                                        message: "Your session code has been copied to clipboard.",
                                        icon: "doc.on.doc.fill",
                                        color: AppColors.primary,
                                        type: .success
                                    )
                                }
                            }) {
                                Text("Copy")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(24)
                    .background(AppColors.cardBackground)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            
            // Joining Overlay
            if appState.isJoiningRoom {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Connecting to \(appState.joiningRoomName)...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(32)
                }
                .transition(.opacity)
                .onAppear {
                    // Automatically dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            let room = appState.joiningRoomName
                            appState.isJoiningRoom = false
                            appState.currentAlert = AppAlert(
                                title: "Room Joined! 🎧",
                                message: "You are now studying in \(room).",
                                icon: "headphones",
                                color: .green,
                                type: .success
                            )
                        }
                    }
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

struct CreateSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
    @State private var roomName = ""
    @State private var selectedSubjectId: UUID?
    @State private var animateItems = false
    
    var body: some View {
        ZStack {
            // Background Glows
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                        
                        // Room Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("WHAT'S THE GOAL?")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            TextField("e.g. Physics Final Revision 🚀", text: $roomName)
                                .font(.system(size: 18, weight: .medium))
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(AppColors.cardBackground)
                                        .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 5)
                                )
                        }
                        .offset(x: animateItems ? 0 : -30)
                        .opacity(animateItems ? 1 : 0)
                        
                        // Subject Grid Selection
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
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            selectedSubjectId = subject.id
                                        }
                                    }
                                }
                            }
                        }
                        .offset(y: animateItems ? 0 : 30)
                        .opacity(animateItems ? 1 : 0)
                        
                        // Dynamic Preview Info
                        if let selectedId = selectedSubjectId, let subj = data.subjects.first(where: { $0.id == selectedId }) {
                            HStack(spacing: 16) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color(hex: subj.colorHex))
                                Text("This room will be tagged as **\(subj.name)**. Students looking for \(subj.name) study groups will find you first.")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .background(Color(hex: subj.colorHex).opacity(0.05))
                            .cornerRadius(20)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
                
                // Bottom Action
                Button(action: {
                    dismiss()
                    withAnimation {
                        let subjName = data.subjects.first(where: { $0.id == selectedSubjectId })?.name ?? "Study"
                        appState.currentAlert = AppAlert(
                            title: "Focus Room Live! 🚀",
                            message: "\(roomName.isEmpty ? "Your session" : roomName) for \(subjName) is now open.",
                            icon: "antenna.radiowaves.left.and.right",
                            color: AppColors.primary,
                            type: .success
                        )
                    }
                }) {
                    HStack {
                        Text("Launch Room")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(24)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(24)
                .disabled(selectedSubjectId == nil)
                .opacity(selectedSubjectId == nil ? 0.5 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateItems = true
            }
        }
    }
}

struct SubjectSelectionCard: View {
    let subject: Subject
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: subject.colorHex) : AppColors.background)
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: subject.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : Color(hex: subject.colorHex))
                }
                
                Text(subject.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: subject.colorHex).opacity(0.1) : AppColors.cardBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color(hex: subject.colorHex) : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.02), radius: 10, x: 0, y: 5)
        }
    }
}

struct GroupSessionCard: View {
    let session: LiveSession
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Host: \(session.host) • \(session.activeMinutes) min active")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Button(action: onJoin) {
                    Text("Join Room")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            HStack(spacing: -10) {
                ForEach(session.participants, id: \.self) { initial in
                    Text(initial)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(circleColor(for: initial))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
    
    func circleColor(for initial: String) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo]
        let index = abs(initial.hashValue) % colors.count
        return colors[index]
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

