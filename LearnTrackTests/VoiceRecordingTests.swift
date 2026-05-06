//
//  VoiceRecordingTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class VoiceRecordingTests: XCTestCase {

    func testVoiceRecordingInitialization() {
        let id = UUID()
        let subjectId = UUID()
        let audioURL = URL(string: "file:///path/to/audio.mp3")
        let waveform: [CGFloat] = [0.1, 0.3, 0.5, 0.2, 0.8]
        
        let recording = VoiceRecording(id: id, title: "Math Lecture", topic: "Algebra", subjectId: subjectId, duration: "45:30", date: "2024-05-06", waveform: waveform, audioURL: audioURL)
        
        XCTAssertEqual(recording.id, id)
        XCTAssertEqual(recording.title, "Math Lecture")
        XCTAssertEqual(recording.topic, "Algebra")
        XCTAssertEqual(recording.subjectId, subjectId)
        XCTAssertEqual(recording.duration, "45:30")
        XCTAssertEqual(recording.date, "2024-05-06")
        XCTAssertEqual(recording.waveform, waveform)
        XCTAssertEqual(recording.audioURL, audioURL)
    }

    func testVoiceRecordingInitializationWithDefaults() {
        let recording = VoiceRecording(title: "Test Recording", topic: "Test Topic", subjectId: nil, duration: "10:00", date: "2024-05-06", waveform: [], audioURL: nil)
        
        XCTAssertNotNil(recording.id)
        XCTAssertEqual(recording.title, "Test Recording")
        XCTAssertEqual(recording.topic, "Test Topic")
        XCTAssertNil(recording.subjectId)
        XCTAssertEqual(recording.duration, "10:00")
        XCTAssertEqual(recording.date, "2024-05-06")
        XCTAssertEqual(recording.waveform, [])
        XCTAssertNil(recording.audioURL)
    }

    func testVoiceRecordingWithEmptyWaveform() {
        let recording = VoiceRecording(title: "Test", topic: "Test", subjectId: nil, duration: "5:00", date: "2024-05-06", waveform: [], audioURL: nil)
        XCTAssertTrue(recording.waveform.isEmpty)
    }

    func testVoiceRecordingWithComplexWaveform() {
        let waveform: [CGFloat] = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0]
        let recording = VoiceRecording(title: "Test", topic: "Test", subjectId: nil, duration: "5:00", date: "2024-05-06", waveform: waveform, audioURL: nil)
        
        XCTAssertEqual(recording.waveform.count, 21)
        XCTAssertEqual(recording.waveform.first, 0.0)
        XCTAssertEqual(recording.waveform.last, 0.0)
    }

    func testVoiceRecordingWithValidAudioURL() {
        let audioURL = URL(string: "https://example.com/audio.mp3")
        let recording = VoiceRecording(title: "Test", topic: "Test", subjectId: nil, duration: "5:00", date: "2024-05-06", waveform: [], audioURL: audioURL)
        
        XCTAssertNotNil(recording.audioURL)
        XCTAssertEqual(recording.audioURL?.absoluteString, "https://example.com/audio.mp3")
    }

    func testVoiceRecordingWithSubject() {
        let subjectId = UUID()
        let recording = VoiceRecording(title: "Subject Recording", topic: "Specific Topic", subjectId: subjectId, duration: "30:00", date: "2024-05-06", waveform: [0.5], audioURL: nil)
        
        XCTAssertNotNil(recording.subjectId)
        XCTAssertEqual(recording.subjectId, subjectId)
    }

    func testVoiceRecordingWithoutSubject() {
        let recording = VoiceRecording(title: "General Recording", topic: "General Topic", subjectId: nil, duration: "15:00", date: "2024-05-06", waveform: [0.3], audioURL: nil)
        
        XCTAssertNil(recording.subjectId)
    }

    func testVoiceRecordingDurationFormats() {
        // Test various duration formats
        let durations = ["1:23", "10:45", "1:00:30", "59:59"]
        
        for duration in durations {
            let recording = VoiceRecording(title: "Test", topic: "Test", subjectId: nil, duration: duration, date: "2024-05-06", waveform: [], audioURL: nil)
            XCTAssertEqual(recording.duration, duration)
        }
    }
}