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
    let userId: UUID
    
    init(id: UUID = UUID(), title: String, topic: String, subjectId: UUID?, duration: String, date: String, waveform: [CGFloat], audioURL: URL?, userId: UUID) {
        self.id = id
        self.title = title
        self.topic = topic
        self.subjectId = subjectId
        self.duration = duration
        self.date = date
        self.waveform = waveform
        self.audioURL = audioURL
        self.userId = userId
    }
    
    init(from dto: VoiceRecordingDTO) {
        self.id = UUID(uuidString: dto.id) ?? UUID()
        self.title = dto.title
        self.topic = dto.topic
        self.subjectId = dto.subjectId.flatMap { UUID(uuidString: $0) }
        self.duration = dto.duration
        self.date = dto.date
        self.waveform = dto.waveform.map { CGFloat($0) }
        self.audioURL = dto.audioFileName.flatMap { URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent($0) }
        self.userId = UUID(uuidString: dto.userId) ?? UUID()
    }
}
