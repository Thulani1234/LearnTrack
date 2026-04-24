//
//  Quiz.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation

struct QuizQuestion: Identifiable, Hashable {
    var id = UUID()
    var question: String
    var options: [String]
    var correctIndex: Int
    var explanation: String?
}

struct Quiz: Identifiable, Hashable {
    var id = UUID()
    var subjectId: UUID
    var title: String
    var dateAttempted: Date
    var score: Int
    var totalQuestions: Int
    var questions: [QuizQuestion]
}
