//
//  ResultTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class ResultTests: XCTestCase {

    func testAcademicResultInitialization() {
        let subjectId = UUID()
        let date = Date()
        let result = AcademicResult(subjectId: subjectId, title: "Midterm Exam", date: date, score: 85, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        
        XCTAssertEqual(result.subjectId, subjectId)
        XCTAssertEqual(result.title, "Midterm Exam")
        XCTAssertEqual(result.date, date)
        XCTAssertEqual(result.score, 85)
        XCTAssertEqual(result.maxScore, 100)
        XCTAssertEqual(result.weight, 30)
        XCTAssertEqual(result.category, .exams)
        XCTAssertEqual(result.targetLabel, "A")
        XCTAssertNotNil(result.id)
    }

    func testAcademicResultPercentage() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 85, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.percentage, 85)
    }

    func testAcademicResultPercentageWithZeroMaxScore() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 85, maxScore: 0, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.percentage, 0)
    }

    func testAcademicResultGrade_A_Plus() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 95, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.grade, "A+")
    }

    func testAcademicResultGrade_A() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 85, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.grade, "A")
    }

    func testAcademicResultGrade_B_Plus() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 75, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.grade, "B+")
    }

    func testAcademicResultGrade_C() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 65, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.grade, "C")
    }

    func testAcademicResultGrade_D() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 45, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.grade, "D")
    }

    func testAcademicResultTargetStatus_Achieved() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 90, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.targetStatus, "Target achieved!")
    }

    func testAcademicResultTargetStatus_BelowTarget() {
        let result = AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 75, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        XCTAssertEqual(result.targetStatus, "15% below target")
    }

    func testAcademicResultHashable() {
        let id = UUID()
        let subjectId = UUID()
        let date = Date()
        let result1 = AcademicResult(id: id, subjectId: subjectId, title: "Test", date: date, score: 85, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        let result2 = AcademicResult(id: id, subjectId: subjectId, title: "Test", date: date, score: 85, maxScore: 100, weight: 30, category: .exams, targetLabel: "A")
        
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result1.hashValue, result2.hashValue)
    }

    func testResultCategory_All() {
        XCTAssertEqual(ResultCategory.all.rawValue, "All")
        XCTAssertEqual(ResultCategory.all.id, "All")
    }

    func testResultCategory_Exams() {
        XCTAssertEqual(ResultCategory.exams.rawValue, "Exams")
        XCTAssertEqual(ResultCategory.exams.id, "Exams")
    }

    func testResultCategory_ClassTests() {
        XCTAssertEqual(ResultCategory.classTests.rawValue, "Class Test")
        XCTAssertEqual(ResultCategory.classTests.id, "Class Test")
    }

    func testResultCategory_Assignments() {
        XCTAssertEqual(ResultCategory.assignments.rawValue, "Assignments")
        XCTAssertEqual(ResultCategory.assignments.id, "Assignments")
    }

    func testResultCategory_AllCases() {
        let allCases = ResultCategory.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.exams))
        XCTAssertTrue(allCases.contains(.classTests))
        XCTAssertTrue(allCases.contains(.assignments))
    }
}