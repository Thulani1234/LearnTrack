//
//  CoreDataExtensions.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

// MARK: - Conversion Extensions for Core Data entities
extension CDSubject {
    func toSubject() -> Subject {
        return Subject(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            colorHex: self.colorHex ?? "#6366F1",
            progress: self.progress,
            targetScore: Int(self.targetScore),
            currentScore: calculateCurrentScore(),
            icon: self.icon ?? "book.fill"
        )
    }
    
    private func calculateCurrentScore() -> Int {
        guard let results = self.results as? Set<CDResult>, !results.isEmpty else {
            return 0
        }
        
        let latestResult = results
            .sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
            .first
        
        return latestResult.map { Int(($0.score * 100) / max($0.maxScore, 1)) } ?? 0
    }
}

extension CDStudySession {
    func toStudySession() -> StudySession {
        return StudySession(
            id: self.id ?? UUID(),
            subjectId: self.subject?.id ?? UUID(),
            date: self.date ?? Date(),
            durationSeconds: Int(self.durationSeconds),
            isCompleted: self.isCompleted,
            summary: self.summary,
            voiceNotePath: self.voiceNotePath
        )
    }
}


extension CDResult {
    func toResult() -> Result {
        let categoryEnum = ResultCategory(rawValue: self.category ?? "all") ?? .all
        return Result(
            id: self.id ?? UUID(),
            subjectId: self.subject?.id ?? UUID(),
            title: self.title ?? "",
            date: self.date ?? Date(),
            score: Int(self.score),
            maxScore: Int(self.maxScore),
            weight: Int(self.weight),
            category: categoryEnum,
            targetLabel: self.targetLabel ?? ""
        )
    }
}
