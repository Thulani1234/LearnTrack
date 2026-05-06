import Foundation
import CoreGraphics

struct VoiceRecording: Identifiable {
    let id: UUID
    let title: String
    let topic: String
    let subjectId: UUID?
    let duration: String
    let date: String
    let waveform: [CGFloat]
    let audioURL: URL?
    
    init(id: UUID = UUID(), title: String, topic: String, subjectId: UUID?, duration: String, date: String, waveform: [CGFloat], audioURL: URL?) {
        self.id = id
        self.title = title
        self.topic = topic
        self.subjectId = subjectId
        self.duration = duration
        self.date = date
        self.waveform = waveform
        self.audioURL = audioURL
    }
}
