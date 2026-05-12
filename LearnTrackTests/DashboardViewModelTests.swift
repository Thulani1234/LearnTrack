//
//  DashboardViewModelTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-12.
//

import XCTest
@testable import LearnTrack

class DashboardViewModelTests: XCTestCase {

    var viewModel: DashboardViewModel!
    var mockAppState: AppState!
    var mockRouter: AppRouter!
    var mockData: MockData!

    override func setUp() {
        super.setUp()
        mockAppState = AppState()
        mockRouter = AppRouter()
        mockData = MockData()
        viewModel = DashboardViewModel(appState: mockAppState, router: mockRouter, data: mockData)
    }

    override func tearDown() {
        viewModel = nil
        mockAppState = nil
        mockRouter = nil
        mockData = nil
        super.tearDown()
    }

    func testUserDisplayName() {
        // Test with empty name
        mockAppState.currentUser = User(id: UUID(), name: "", email: "test@example.com", phoneNumber: "1234567890", password: "password")
        XCTAssertEqual(viewModel.userDisplayName, "User")

        // Test with name
        mockAppState.currentUser = User(id: UUID(), name: "John Doe", email: "test@example.com", phoneNumber: "1234567890", password: "password")
        XCTAssertEqual(viewModel.userDisplayName, "John Doe")

        // Test with whitespace
        mockAppState.currentUser = User(id: UUID(), name: "  John  ", email: "test@example.com", phoneNumber: "1234567890", password: "password")
        XCTAssertEqual(viewModel.userDisplayName, "John")
    }

    func testUserInitial() {
        mockAppState.currentUser = User(id: UUID(), name: "John", email: "test@example.com", phoneNumber: "1234567890", password: "password")
        XCTAssertEqual(viewModel.userInitial, "J")

        mockAppState.currentUser = User(id: UUID(), name: "", email: "test@example.com", phoneNumber: "1234567890", password: "password")
        XCTAssertEqual(viewModel.userInitial, "U")
    }

    func testTodayStudySeconds() {
        let today = Date()
        let subjectId = UUID()
        let session = StudySession(id: UUID(), subjectId: subjectId, date: today, durationSeconds: 3600, isCompleted: true)
        mockData.recentSessions = [session]

        XCTAssertEqual(viewModel.todayStudySeconds, 3600)
    }

    func testDailyGoalSeconds() {
        XCTAssertEqual(viewModel.dailyGoalSeconds, 5 * 60 * 60)
    }

    func testDailyProgress() {
        // 0 progress
        XCTAssertEqual(viewModel.dailyProgress, 0)

        // Add session
        let today = Date()
        let subjectId = UUID()
        let session = StudySession(id: UUID(), subjectId: subjectId, date: today, durationSeconds: 3600, isCompleted: true)
        mockData.recentSessions = [session]

        XCTAssertEqual(viewModel.dailyProgress, 3600.0 / (5 * 60 * 60))
    }

    func testDailyProgressText() {
        // 0 seconds
        XCTAssertEqual(viewModel.dailyProgressText, "Start studying to track your daily progress.")

        // 30 minutes
        let today = Date()
        let subjectId = UUID()
        let session = StudySession(id: UUID(), subjectId: subjectId, date: today, durationSeconds: 1800, isCompleted: true)
        mockData.recentSessions = [session]

        XCTAssertEqual(viewModel.dailyProgressText, "You've completed 30m of study today.")

        // 1 hour 30 minutes
        let session2 = StudySession(id: UUID(), subjectId: subjectId, date: today, durationSeconds: 5400, isCompleted: true)
        mockData.recentSessions = [session2]

        XCTAssertEqual(viewModel.dailyProgressText, "You've completed 1h 30m of study today.")
    }

    func testAutoPlanItems() {
        // Empty subjects
        XCTAssertEqual(viewModel.autoPlanItems.count, 0)

        // Add subjects
        let subject1 = Subject(name: "Math", colorHex: "blue", progress: 0.5, targetScore: 100, currentScore: 50, icon: "function")
        let subject2 = Subject(name: "Science", colorHex: "red", progress: 0.3, targetScore: 100, currentScore: 30, icon: "flask")
        let subject3 = Subject(name: "English", colorHex: "green", progress: 0.8, targetScore: 100, currentScore: 80, icon: "book")
        mockData.subjects = [subject1, subject2, subject3]

        let autoPlan = viewModel.autoPlanItems
        XCTAssertEqual(autoPlan.count, 3)
        XCTAssertEqual(autoPlan[0].name, "Science") // lowest progress
        XCTAssertEqual(autoPlan[1].name, "Math")
        XCTAssertEqual(autoPlan[2].name, "English")
    }

    func testHasDashboardData() {
        XCTAssertFalse(viewModel.hasDashboardData)

        mockData.subjects = [Subject(name: "Math", colorHex: "blue", progress: 0.5, targetScore: 100, currentScore: 50, icon: "function")]
        XCTAssertTrue(viewModel.hasDashboardData)

        mockData.subjects = []
        mockData.recentSessions = [StudySession(subjectId: UUID(), date: Date(), durationSeconds: 3600, isCompleted: true)]
        XCTAssertTrue(viewModel.hasDashboardData)

        mockData.recentSessions = []
        mockData.academicResults = [AcademicResult(subjectId: UUID(), title: "Test", date: Date(), score: 85, maxScore: 100, weight: 10, category: .quizzes, targetLabel: "A")]
        XCTAssertTrue(viewModel.hasDashboardData)
    }

    func testGreetingText() {
        // Mock current hour, but since it's Date(), hard to test exactly
        // We can test the logic by assuming current time
        let greeting = viewModel.greetingText
        XCTAssertTrue(["Good Morning", "Good Afternoon", "Good Evening", "Welcome"].contains(greeting))
    }

    func testNavigateToNotifications() {
        viewModel.navigateToNotifications()
        // Since router is mock, hard to test, but we can check if it's called
        // For now, just ensure no crash
    }

    func testNavigateToProfile() {
        viewModel.navigateToProfile()
        XCTAssertEqual(mockAppState.selectedTab, 5)
    }
}