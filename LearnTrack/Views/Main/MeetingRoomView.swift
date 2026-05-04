import SwiftUI

struct MeetingRoomView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    var roomName: String
    
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var isScreenSharing = false
    @State private var showingParticipants = false
    @State private var animatePulse = false
    
    let participants = [
        ("Sara", "S", Color.orange),
        ("Ahmed", "A", Color.blue),
        ("Mike", "M", Color.green),
        ("Jessica", "J", Color.purple),
        ("You", "Y", AppColors.primary)
    ]
    
    var body: some View {
        ZStack {
            // Dark Background for Video Meeting Feel
            Color(hex: "121212").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(roomName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        HStack {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("Live • 00:45:12")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { showingParticipants.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                Text("\(participants.count)")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
                
                // Main Content (Grid of Participants)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(participants, id: \.0) { participant in
                            ParticipantCard(
                                name: participant.0,
                                initial: participant.1,
                                color: participant.2,
                                isMe: participant.0 == "You",
                                isCameraOff: participant.0 == "You" ? isCameraOff : false
                            )
                        }
                    }
                    .padding(16)
                }
                
                Spacer()
                
                // Bottom Controls Bar
                VStack(spacing: 24) {
                    // Quick Quote or Motivation
                    Text("Stay focused, team! 🚀")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 20) {
                        // Mic Button
                        ControlCircleButton(
                            icon: isMuted ? "mic.slash.fill" : "mic.fill",
                            color: isMuted ? .red : .white.opacity(0.1),
                            iconColor: isMuted ? .white : .white
                        ) {
                            withAnimation { isMuted.toggle() }
                        }
                        
                        // Camera Button
                        ControlCircleButton(
                            icon: isCameraOff ? "video.slash.fill" : "video.fill",
                            color: isCameraOff ? .red : .white.opacity(0.1),
                            iconColor: isCameraOff ? .white : .white
                        ) {
                            withAnimation { isCameraOff.toggle() }
                        }
                        
                        // Share Button
                        ControlCircleButton(
                            icon: "square.and.arrow.up.fill",
                            color: isScreenSharing ? AppColors.primary : .white.opacity(0.1),
                            iconColor: .white
                        ) {
                            withAnimation { isScreenSharing.toggle() }
                        }
                        
                        // Leave Button (The one requested)
                        Button(action: {
                            router.navigateBack()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.down.fill")
                                Text("Leave")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(24)
                            .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
                .background(
                    LinearGradient(colors: [Color.clear, Color.black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .navigationBarHidden(true)
    }
}

struct ParticipantCard: View {
    let name: String
    let initial: String
    let color: Color
    let isMe: Bool
    var isCameraOff: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
            
            if isCameraOff {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Text(initial)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(color)
                    }
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                // Placeholder for Video
                ZStack {
                    color.opacity(0.1)
                    VStack {
                        Spacer()
                        HStack {
                            Text(name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(8)
                            Spacer()
                            if isMe {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(12)
                    }
                }
                .cornerRadius(24)
            }
            
            // Highlight for active speaker
            if name == "Ahmed" {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppColors.primary, lineWidth: 3)
            }
        }
        .frame(height: 180)
    }
}

struct ControlCircleButton: View {
    let icon: String
    let color: Color
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
        }
    }
}
