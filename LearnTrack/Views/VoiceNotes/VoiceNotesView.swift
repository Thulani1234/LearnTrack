import SwiftUI

struct VoiceRecording: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let date: String
    let waveform: [CGFloat]
}

struct VoiceNotesView: View {
    @EnvironmentObject var router: AppRouter
    @State private var isRecording = false
    @State private var searchText = ""
    @State private var recordingTime = 0
    @State private var timer: Timer? = nil
    
    @State private var mockRecordings = [
        VoiceRecording(title: "Biology Lecture - Cells", duration: "12:45", date: "Today", waveform: [0.2, 0.5, 0.3, 0.8, 0.4, 0.6, 0.3, 0.5]),
        VoiceRecording(title: "Math Formulas Recap", duration: "05:20", date: "Yesterday", waveform: [0.4, 0.3, 0.6, 0.2, 0.5, 0.8, 0.4, 0.3]),
        VoiceRecording(title: "History Project Ideas", duration: "02:15", date: "24 Apr", waveform: [0.3, 0.4, 0.5, 0.3, 0.4, 0.2, 0.6, 0.4])
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.navigateBack() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.headline)
                            .padding(12)
                            .background(AppColors.cardBackground)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Voice Notes")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding()
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)
                    TextField("Search your recordings...", text: $searchText)
                        .font(AppTypography.body)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(mockRecordings) { recording in
                            RecordingCard(recording: recording)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 150)
                }
            }
            
            // Recording Controls Area
            VStack(spacing: 20) {
                if isRecording {
                    HStack(spacing: 4) {
                        ForEach(0..<15) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppColors.error)
                                .frame(width: 3, height: .random(in: 10...40))
                                .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.05), value: isRecording)
                        }
                    }
                    .frame(height: 50)
                    
                    Text(timeString(time: recordingTime))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? AppColors.error.opacity(0.1) : AppColors.primary.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .scaleEffect(isRecording ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: isRecording)
                        
                        Circle()
                            .fill(isRecording ? AppColors.error : AppColors.primary)
                            .frame(width: 70, height: 70)
                            .shadow(color: (isRecording ? AppColors.error : AppColors.primary).opacity(0.4), radius: 15, x: 0, y: 10)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [AppColors.background.opacity(0), AppColors.background], startPoint: .top, endPoint: .bottom)
                    .padding(.top, -50)
            )
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func toggleRecording() {
        withAnimation(.spring()) {
            isRecording.toggle()
            if isRecording {
                startTimer()
            } else {
                stopTimer()
                mockRecordings.insert(VoiceRecording(title: "New Note \(mockRecordings.count + 1)", duration: timeString(time: recordingTime), date: "Today", waveform: [0.3, 0.6, 0.4, 0.7, 0.2, 0.5, 0.3, 0.4]), at: 0)
                recordingTime = 0
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RecordingCard: View {
    let recording: VoiceRecording
    
    var body: some View {
        HStack(spacing: 16) {
            // Waveform Preview
            HStack(spacing: 3) {
                ForEach(recording.waveform, id: \.self) { height in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppColors.primary.opacity(0.5))
                        .frame(width: 2, height: height * 30)
                }
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Text(recording.date)
                    Text("•")
                    Text(recording.duration)
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(AppColors.primary)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}
