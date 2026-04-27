//
//  StudySession.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation

struct StudySession: Identifiable, Hashable {
    var id = UUID()
    var subjectId: UUID
    var date: Date
    var durationSeconds: Int
    var isCompleted: Bool
    var summary: String?
    var voiceNotePath: String?
}
