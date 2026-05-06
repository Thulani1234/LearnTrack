//
//  DatabaseChecker.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

class DatabaseChecker {
    static let shared = DatabaseChecker()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // MARK: - Quick Database Check Methods
    
    func checkDatabaseStatus() -> String {
        let report = DataMigrationService.shared.verifyDataIntegrity()
        return report.summary
    }
    
    func printDatabaseContents() {
        print("=== DATABASE CONTENTS ===")
        
        // Subjects
        let subjects = coreDataManager.fetchSubjects()
        print("\n📚 SUBJECTS (\(subjects.count)):")
        for subject in subjects {
            let subjectModel = subject.toSubject()
            print("  - \(subjectModel.name) (Progress: \(subjectModel.progress * 100)%)")
        }
        
        // Study Sessions
        let studySessions = coreDataManager.fetchStudySessions()
        print("\n📖 STUDY SESSIONS (\(studySessions.count)):")
        for session in studySessions.prefix(5) {
            let sessionModel = session.toStudySession()
            print("  - \(sessionModel.date): \(sessionModel.durationSeconds/60) minutes \(sessionModel.isCompleted ? "✅" : "⏳")")
        }
        if studySessions.count > 5 {
            print("  ... and \(studySessions.count - 5) more")
        }
        

        // Results
        let results = coreDataManager.fetchResults()
        print("\n📊 RESULTS (\(results.count)):")
        for result in results.prefix(3) {
            let resultModel = result.toAcademicResult()
            print("  - \(resultModel.title): \(resultModel.score)% (\(resultModel.grade))")
        }
        if results.count > 3 {
            print("  ... and \(results.count - 3) more")
        }
        
        print("\n=== END DATABASE CONTENTS ===")
    }
    
    func testCRUDOperations() -> String {
        var results: [String] = []
        
        // Test Create
        results.append("🔧 Testing CREATE operations...")
        let testSubject = Subject(name: "Test Subject", colorHex: "#FF0000", progress: 0.5, targetScore: 90, currentScore: 85, icon: "test")
        
        let context = coreDataManager.viewContext
        let cdTestSubject = CDSubject(context: context)
        cdTestSubject.id = UUID()
        cdTestSubject.name = testSubject.name
        cdTestSubject.colorHex = testSubject.colorHex
        cdTestSubject.progress = testSubject.progress
        cdTestSubject.targetScore = Int32(testSubject.targetScore)
        cdTestSubject.icon = testSubject.icon
        cdTestSubject.createdDate = Date()
        cdTestSubject.updatedDate = Date()
        
        do {
            try context.save()
            results.append("✅ Subject created successfully")
        } catch {
            results.append("❌ Failed to create subject: \(error)")
        }
        
        // Test Read
        results.append("🔧 Testing READ operations...")
        let subjects = coreDataManager.fetchSubjects()
        if subjects.count > 0 {
            results.append("✅ Read \(subjects.count) subjects successfully")
        } else {
            results.append("❌ No subjects found")
        }
        
        // Test Update
        results.append("🔧 Testing UPDATE operations...")
        if let firstSubject = subjects.first {
            firstSubject.name = "Updated Test Subject"
            firstSubject.updatedDate = Date()
            do {
                try context.save()
                results.append("✅ Subject updated successfully")
            } catch {
                results.append("❌ Failed to update subject: \(error)")
            }
        }
        
        // Test Delete
        results.append("🔧 Testing DELETE operations...")
        if let firstSubject = subjects.first, firstSubject.name == "Updated Test Subject" {
            context.delete(firstSubject)
            do {
                try context.save()
                results.append("✅ Subject deleted successfully")
            } catch {
                results.append("❌ Failed to delete subject: \(error)")
            }
        }
        
        return results.joined(separator: "\n")
    }
    
    func getDatabaseStatistics() -> String {
        let subjects = coreDataManager.fetchSubjects()
        let studySessions = coreDataManager.fetchStudySessions()
        let results = coreDataManager.fetchResults()
        
        var stats = "📊 DATABASE STATISTICS\n"
        stats += "===================\n"
        stats += "Subjects: \(subjects.count)\n"
        stats += "Study Sessions: \(studySessions.count)\n"
        stats += "Results: \(results.count)\n"
        
        // Calculate additional stats
        if !studySessions.isEmpty {
            let totalMinutes = studySessions.reduce(0) { $0 + $1.durationSeconds } / 60
            stats += "Total Study Time: \(totalMinutes) minutes\n"
        }
        
        
        if !results.isEmpty {
            let averageResultScore = results.reduce(0) { $0 + Int($1.score) } / results.count
            stats += "Average Result Score: \(averageResultScore)%\n"
        }
        
        return stats
    }
}
