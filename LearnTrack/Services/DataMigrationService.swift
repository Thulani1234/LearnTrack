//
//  DataMigrationService.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

class DataMigrationService {
    static let shared = DataMigrationService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    func performInitialMigrationIfNeeded() {
        if isDatabaseEmpty() {
            print("Database is empty, performing initial migration...")
            migrateMockData()
        } else {
            print("Database already contains data, skipping migration")
        }
    }
    
    func syncMockDataToCoreData() {
        print("Starting sync of mock data to Core Data...")
        migrateMockData()
        print("Sync completed")
    }
    
    func verifyDataIntegrity() -> MigrationReport {
        let report = MigrationReport()
        
        // Check subjects
        let subjects = coreDataManager.fetchSubjects()
        report.subjectsCount = subjects.count
        if subjects.isEmpty {
            report.addError("No subjects found in database")
        }
        
        // Check study sessions
        let studySessions = coreDataManager.fetchStudySessions()
        report.studySessionsCount = studySessions.count
        if studySessions.isEmpty {
            report.addWarning("No study sessions found in database")
        }
        
        
        // Check results
        let results = coreDataManager.fetchResults()
        report.resultsCount = results.count
        if results.isEmpty {
            report.addWarning("No results found in database")
        }
        
        return report
    }
    
    private func isDatabaseEmpty() -> Bool {
        let subjects = coreDataManager.fetchSubjects()
        return subjects.isEmpty
    }
    
    private func migrateMockData() {
        let mockData = MockData.shared
        
        // Clear existing data
        coreDataManager.deleteAllData()
        
        // Create subjects
        for subject in mockData.subjects {
            createSubject(from: subject)
        }
        
        // Create study sessions
        for session in mockData.recentSessions + mockData.scheduledSessions {
            createStudySession(from: session)
        }
        
        // Create results
        for result in mockData.academicResults {
            createResult(from: result)
        }
        
        // Seed sample users
        let userSeeder = UserDataSeeder.shared
        userSeeder.seedSampleUsers()
                
        print("Mock data migration completed")
    }
    
    private func createSubject(from subject: Subject) {
        let context = coreDataManager.viewContext
        let cdSubject = CDSubject(context: context)
        
        cdSubject.id = subject.id
        cdSubject.name = subject.name
        cdSubject.colorHex = subject.colorHex
        cdSubject.progress = subject.progress
        cdSubject.targetScore = Int32(subject.targetScore)
        cdSubject.icon = subject.icon
        cdSubject.createdDate = Date()
        cdSubject.updatedDate = Date()
        
        coreDataManager.saveContext()
    }
    
    private func createStudySession(from session: StudySession) {
        let context = coreDataManager.viewContext
        let cdSession = CDStudySession(context: context)
        
        cdSession.id = session.id
        cdSession.date = session.date
        cdSession.durationSeconds = Int32(session.durationSeconds)
        cdSession.isCompleted = session.isCompleted
        cdSession.summary = session.summary
        cdSession.voiceNotePath = session.voiceNotePath
        
        // Find subject (simplified - in real implementation you'd match by ID)
        let subjects = coreDataManager.fetchSubjects()
        if let firstSubject = subjects.first {
            cdSession.subject = firstSubject
        }
        
        coreDataManager.saveContext()
    }
    
    
    private func createResult(from result: AcademicResult) {
        let context = coreDataManager.viewContext
        let cdResult = CDResult(context: context)
        
        cdResult.id = result.id
        cdResult.title = result.title
        cdResult.date = result.date
        cdResult.score = Int32(result.score)
        cdResult.maxScore = Int32(result.maxScore)
        cdResult.weight = Int32(result.weight)
        cdResult.category = result.category.rawValue
        cdResult.targetLabel = result.targetLabel
        
        // Find subject
        let subjects = coreDataManager.fetchSubjects()
        if let firstSubject = subjects.first {
            cdResult.subject = firstSubject
        }
        
        coreDataManager.saveContext()
    }
    
    // MARK: - Voice Data Management
    func seedVoiceDataOnly() {
        print("Voice data seeding temporarily disabled")
        // let voiceSeeder = VoiceDataSeeder.shared
        // voiceSeeder.seedVoiceData()
        print("")
    }
    
    func seedVoiceDataForSubject(subjectId: UUID) {
        print("Voice data seeding temporarily disabled")
        // let voiceSeeder = VoiceDataSeeder.shared
        // voiceSeeder.seedVoiceDataForSubject(subjectId: subjectId)
        print("")
        // print("Subject voice data seeding completed")
    }
    
    func clearVoiceDataOnly() {
        print("Voice data clearing temporarily disabled")
        // let voiceSeeder = VoiceDataSeeder.shared
        // voiceSeeder.clearVoiceData()
        // print("Voice data clearing completed")
    }
    
    func regenerateVoiceData() {
        print("Regenerating voice data...")
        clearVoiceDataOnly()
        seedVoiceDataOnly()
        print("Voice data regeneration completed")
    }
}

class MigrationReport {
    var subjectsCount = 0
    var studySessionsCount = 0
    var resultsCount = 0
    private var errors: [String] = []
    private var warnings: [String] = []
    
    func addError(_ message: String) {
        errors.append(message)
    }
    
    func addWarning(_ message: String) {
        warnings.append(message)
    }
    
    var hasErrors: Bool {
        !errors.isEmpty
    }
    
    var hasWarnings: Bool {
        !warnings.isEmpty
    }
    
    var summary: String {
        var summary = "Migration Report:\n"
        summary += "- Subjects: \(subjectsCount)\n"
        summary += "- Study Sessions: \(studySessionsCount)\n"
        summary += "- Results: \(resultsCount)\n"
        
        if hasErrors {
            summary += "\nErrors:\n"
            for error in errors {
                summary += "- \(error)\n"
            }
        }
        
        if hasWarnings {
            summary += "\nWarnings:\n"
            for warning in warnings {
                summary += "- \(warning)\n"
            }
        }
        
        if !hasErrors && !hasWarnings {
            summary += "\nMigration completed successfully!"
        }
        
        return summary
    }
}
