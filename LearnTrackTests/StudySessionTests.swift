//
//  StudySessionTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class StudySessionTests: XCTestCase {

    func testStudySessionInitialization() {
        let subjectId = UUID()
        let date = Date()
        let session = StudySession(subjectId: subjectId, date: date, durationSeconds: 3600, isCompleted: true, summary: "Good session", voiceNotePath: "/path/to/note")
        XCTAssertEqual(session.subjectId, subjectId)
        XCTAssertEqual(session.date, date)
        XCTAssertEqual(session.durationSeconds, 3600)
        XCTAssertTrue(session.isCompleted)
        XCTAssertEqual(session.summary, "Good session")
        XCTAssertEqual(session.voiceNotePath, "/path/to/note")
        XCTAssertNotNil(session.id)
    }

    func testStudySessionHashable() {
        let id = UUID()
        let subjectId = UUID()
        let date = Date()
        let session1 = StudySession(id: id, subjectId: subjectId, date: date, durationSeconds: 1800, isCompleted: false, summary: nil, voiceNotePath: nil)
        let session2 = StudySession(id: id, subjectId: subjectId, date: date, durationSeconds: 1800, isCompleted: false, summary: nil, voiceNotePath: nil)
        XCTAssertEqual(session1, session2)
        XCTAssertEqual(session1.hashValue, session2.hashValue)
    }
}