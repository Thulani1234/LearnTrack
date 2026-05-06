import SwiftUI
import AVFoundation
import Combine

struct VoiceNotesView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var data: MockData
    @State private var isRecording = false
    @State private var searchText = ""
    @State private var recordingTime = 0
    @State private var selectedSubjectId: UUID?
    @State private var timer: Timer? = nil
    
    
    // Recordings now come from data.voiceRecordings
    
    @StateObject private var audioManager = AudioManager()
    
    // New states for saving
    @State private var showingSaveSheet = false
    @State private var newTopic = ""
    @State private var newSubjectId: UUID?
    @State private var lastRecordingTime = 0
    @State private var lastAudioURL: URL?
    
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
                
                // Subject Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedSubjectId = nil }) {
                            Text("All")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(selectedSubjectId == nil ? .white : AppColors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedSubjectId == nil ? AppColors.primary : AppColors.cardBackground)
                                .cornerRadius(15)
                        }
                        
                        ForEach(data.subjects) { subject in
                            Button(action: { selectedSubjectId = subject.id }) {
                                HStack(spacing: 6) {
                                    Image(systemName: subject.icon)
                                    Text(subject.name)
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(selectedSubjectId == subject.id ? .white : AppColors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedSubjectId == subject.id ? AppColors.primary : AppColors.cardBackground)
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(data.voiceRecordings.filter { recording in
                            let matchesSearch = searchText.isEmpty || 
                                recording.title.lowercased().contains(searchText.lowercased()) || 
                                recording.topic.lowercased().contains(searchText.lowercased())
                            let matchesSubject = selectedSubjectId == nil || recording.subjectId == selectedSubjectId
                            return matchesSearch && matchesSubject
                        }) { recording in
                            RecordingCard(
                                recording: recording, 
                                subjectName: data.subjects.first(where: { $0.id == recording.subjectId })?.name ?? "General",
                                isPlaying: audioManager.playingURL == recording.audioURL && audioManager.isPlaying,
                                onPlay: {
                                    if let url = recording.audioURL {
                                        if audioManager.playingURL == url && audioManager.isPlaying {
                                            audioManager.stopPlayback()
                                        } else {
                                            audioManager.play(url: url)
                                        }
                                    }
                                }
                            )
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
        .sheet(isPresented: $showingSaveSheet) {
            SaveVoiceNoteSheet(topic: $newTopic, selectedSubjectId: $newSubjectId, subjects: data.subjects) {
                saveRecording()
            }
        }
        .onAppear {
            // No longer seeding non-playable recordings
        }
    }
    
    private func toggleRecording() {
        withAnimation(.spring()) {
            if isRecording {
                stopTimer()
                lastAudioURL = audioManager.stopRecording()
                lastRecordingTime = recordingTime
                newSubjectId = selectedSubjectId
                showingSaveSheet = true
                isRecording = false
            } else {
                recordingTime = 0
                startTimer()
                audioManager.startRecording()
                isRecording = true
            }
        }
    }
    
    private func saveRecording() {
        let subjectName = data.subjects.first(where: { $0.id == newSubjectId })?.name ?? "General"
        let recording = VoiceRecording(
            title: "\(subjectName) Note",
            topic: newTopic,
            subjectId: newSubjectId,
            duration: timeString(time: lastRecordingTime),
            date: "Today",
            waveform: (0..<8).map { _ in CGFloat.random(in: 0.2...0.9) },
            audioURL: lastAudioURL
        )
        data.addVoiceRecording(recording)
        
        // Reset
        newTopic = ""
        lastAudioURL = nil
        showingSaveSheet = false
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
    let subjectName: String
    var isPlaying: Bool = false
    var onPlay: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Waveform Preview
            HStack(spacing: 3) {
                ForEach(recording.waveform, id: \.self) { height in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isPlaying ? AppColors.primary : AppColors.primary.opacity(0.5))
                        .frame(width: 2, height: height * (isPlaying ? 40 : 30))
                        .animation(.easeInOut, value: isPlaying)
                }
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.topic)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    Text(subjectName)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.primary.opacity(0.1))
                        .foregroundColor(AppColors.primary)
                        .cornerRadius(4)
                    
                    Text(recording.date)
                    Text("•")
                    Text(recording.duration)
                }
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: onPlay) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(isPlaying ? AppColors.error : AppColors.primary)
                    .clipShape(Circle())
            }
            .disabled(recording.audioURL == nil && !isPlaying)
            .opacity(recording.audioURL == nil && !isPlaying ? 0.5 : 1.0)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var playingURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let fileName = "recording-\(UUID().uuidString).m4a"
            let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            recordingURL = path
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: path, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        return recordingURL
    }
    
    func play(url: URL) {
        // Stop current if playing
        if isPlaying {
            stopPlayback()
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            playingURL = url
        } catch {
            print("Failed to play: \(error)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        playingURL = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playingURL = nil
        }
    }
}

struct SaveVoiceNoteSheet: View {
    @Binding var topic: String
    @Binding var selectedSubjectId: UUID?
    let subjects: [Subject]
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Note Topic")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    TextField("What's this recording about?", text: $topic)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Subject")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(subjects) { subject in
                                Button(action: { selectedSubjectId = subject.id }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: subject.icon)
                                            .font(.title3)
                                        Text(subject.name)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(selectedSubjectId == subject.id ? AppColors.primary : AppColors.cardBackground)
                                    .foregroundColor(selectedSubjectId == subject.id ? .white : AppColors.textSecondary)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.primary.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onSave) {
                    Text("Save Voice Note")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(topic.isEmpty ? Color.gray : AppColors.primary)
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(topic.isEmpty)
            }
            .padding()
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Save Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
