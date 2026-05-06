//
//  SubjectTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class SubjectTests: XCTestCase {

    func testSubjectInitialization() {
        let subject = Subject(name: "Mathematics", colorHex: "#FF0000", progress: 0.5, targetScore: 100, currentScore: 50, icon: "math")
        XCTAssertEqual(subject.name, "Mathematics")
        XCTAssertEqual(subject.colorHex, "#FF0000")
        XCTAssertEqual(subject.progress, 0.5)
        XCTAssertEqual(subject.targetScore, 100)
        XCTAssertEqual(subject.currentScore, 50)
        XCTAssertEqual(subject.icon, "math")
        XCTAssertNotNil(subject.id)
    }

    func testSubjectHashable() {
        let subject1 = Subject(id: UUID(), name: "Math", colorHex: "#FF0000", progress: 0.5, targetScore: 100, currentScore: 50, icon: "math")
        let subject2 = Subject(id: subject1.id, name: "Math", colorHex: "#FF0000", progress: 0.5, targetScore: 100, currentScore: 50, icon: "math")
        XCTAssertEqual(subject1, subject2)
        XCTAssertEqual(subject1.hashValue, subject2.hashValue)
    }
}