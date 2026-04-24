//
//  MockData.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import Combine

class MockData: ObservableObject {
    // We use inner structs specifically for MockData UI usage if needed, or directly use the actual Models
    
    static let shared = MockData()
    
    @Published var subjects: [Subject]
    @Published var recentSessions: [StudySession]
    @Published var scheduledSessions: [StudySession]
    @Published var quizzes: [Quiz]
    @Published var academicResults: [Result]
    
    private init() {
        let initialSubjects = [
            Subject(name: "Mathematics", colorHex: "6366F1", progress: 0.7, targetScore: 95, currentScore: 89),
            Subject(name: "Science", colorHex: "14B8A6", progress: 0.4, targetScore: 90, currentScore: 75),
            Subject(name: "English", colorHex: "F59E0B", progress: 0.9, targetScore: 85, currentScore: 82),
            Subject(name: "ICT", colorHex: "A855F7", progress: 0.6, targetScore: 100, currentScore: 92)
        ]
        subjects = initialSubjects
        
        recentSessions = [
            StudySession(subjectId: UUID(), date: Date(), durationMinutes: 45, isCompleted: true, summary: "Completed algebra practice."),
            StudySession(subjectId: UUID(), date: Date().addingTimeInterval(-86400), durationMinutes: 30, isCompleted: true, summary: "Read chapter 3 of biology.")
        ]
        
        scheduledSessions = [
            StudySession(subjectId: UUID(), date: Date().addingTimeInterval(3600), durationMinutes: 60, isCompleted: false),
            StudySession(subjectId: UUID(), date: Date().addingTimeInterval(86400 * 2), durationMinutes: 45, isCompleted: false)
        ]
        
        quizzes = [
            Quiz(
                subjectId: UUID(),
                title: "Algebra Quiz",
                dateAttempted: Date().addingTimeInterval(-86400 * 3),
                score: 8,
                totalQuestions: 4,
                questions: [
                    QuizQuestion(
                        question: "What is the solution to x^2 - 5x + 6 = 0?",
                        options: ["x = 2 or x = 3", "x = -2 or x = -3", "x = 5", "x = 6"],
                        correctIndex: 0,
                        explanation: "Factoring gives (x-2)(x-3)=0, so x=2 or x=3."
                    ),
                    QuizQuestion(
                        question: "Which expression represents the area of a circle?",
                        options: ["2πr", "πr²", "πd", "r²"],
                        correctIndex: 1,
                        explanation: "The area formula for a circle is π times the radius squared."
                    ),
                    QuizQuestion(
                        question: "Simplify: 3(2x - 4) + 5",
                        options: ["6x - 7", "6x + 1", "2x - 7", "6x - 5"],
                        correctIndex: 0,
                        explanation: "Distribute then add: 6x - 12 + 5 = 6x - 7."
                    ),
                    QuizQuestion(
                        question: "What is the slope of a line with equation y = 4x + 1?",
                        options: ["1", "4", "-4", "0"],
                        correctIndex: 1,
                        explanation: "The slope is the coefficient of x, which is 4."
                    )
                ]
            ),
            Quiz(
                subjectId: UUID(),
                title: "Grammar Quiz",
                dateAttempted: Date().addingTimeInterval(-86400 * 5),
                score: 7,
                totalQuestions: 4,
                questions: [
                    QuizQuestion(
                        question: "Which sentence shows correct subject-verb agreement?",
                        options: ["The dogs runs fast.", "He go to school.", "She likes reading.", "They is happy."],
                        correctIndex: 2,
                        explanation: "She likes reading uses the correct third-person singular verb form."
                    ),
                    QuizQuestion(
                        question: "Choose the correct version of the sentence:",
                        options: ["Its raining outside.", "It’s raining outside.", "Its’ raining outside.", "It raining outside."],
                        correctIndex: 1,
                        explanation: "It’s is the contraction for it is, which is correct here."
                    ),
                    QuizQuestion(
                        question: "What is the past tense of the verb 'to begin'?",
                        options: ["begun", "began", "begins", "begined"],
                        correctIndex: 1,
                        explanation: "The correct past tense is began."
                    ),
                    QuizQuestion(
                        question: "Choose the sentence with correct punctuation:",
                        options: ["Lets eat grandma.", "Let’s eat, grandma.", "Lets eat, grandma.", "Let’s eat grandma."],
                        correctIndex: 1,
                        explanation: "The comma and contraction are both correct."
                    )
                ]
            )
        ]
        
        academicResults = [
            Result(
                subjectId: initialSubjects[1].id,
                title: "Mid-term Exam",
                date: Date().addingTimeInterval(-86400 * 4),
                score: 78,
                maxScore: 100,
                weight: 30,
                category: .exams,
                targetLabel: "A"
            ),
            Result(
                subjectId: initialSubjects[3].id,
                title: "Data Structures Project",
                date: Date().addingTimeInterval(-86400 * 7),
                score: 85,
                maxScore: 100,
                weight: 30,
                category: .projects,
                targetLabel: "A"
            ),
            Result(
                subjectId: initialSubjects[0].id,
                title: "Algebra Final Exam",
                date: Date().addingTimeInterval(-86400 * 16),
                score: 58,
                maxScore: 100,
                weight: 35,
                category: .exams,
                targetLabel: "B+"
            ),
            Result(
                subjectId: initialSubjects[2].id,
                title: "Essay Assignment",
                date: Date().addingTimeInterval(-86400 * 20),
                score: 92,
                maxScore: 100,
                weight: 20,
                category: .assignments,
                targetLabel: "A"
            )
        ]
    }
    
    func addResult(
        title: String,
        subjectId: UUID,
        score: Int,
        maxScore: Int,
        weight: Int,
        category: ResultCategory,
        targetLabel: String,
        date: Date = Date()
    ) {
        let result = Result(
            subjectId: subjectId,
            title: title,
            date: date,
            score: score,
            maxScore: maxScore,
            weight: weight,
            category: category,
            targetLabel: targetLabel
        )
        academicResults.append(result)
        updateSubjectMetrics(for: subjectId)
    }
    
    func updateResult(_ updatedResult: Result) {
        guard let index = academicResults.firstIndex(where: { $0.id == updatedResult.id }) else { return }
        let oldSubjectId = academicResults[index].subjectId
        academicResults[index] = updatedResult
        updateSubjectMetrics(for: oldSubjectId)
        updateSubjectMetrics(for: updatedResult.subjectId)
    }
    
    func subject(for id: UUID) -> Subject? {
        subjects.first(where: { $0.id == id })
    }
    
    private func updateSubjectMetrics(for subjectId: UUID) {
        guard let index = subjects.firstIndex(where: { $0.id == subjectId }) else { return }
        let currentResult = academicResults
            .filter { $0.subjectId == subjectId }
            .sorted(by: { $0.date > $1.date })
            .first
        let newScore = currentResult?.percentage ?? subjects[index].currentScore
        subjects[index].currentScore = newScore
        subjects[index].progress = Double(min(max(newScore, 0), 100)) / 100.0
    }
    
    // Type aliases for AppRouter
    typealias SubjectMock = Subject
    typealias QuizMock = Quiz
}
