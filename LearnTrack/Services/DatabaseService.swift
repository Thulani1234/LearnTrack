//
//  DatabaseService.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData
import Combine

class DatabaseService: ObservableObject {
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Subject Operations
    func createSubject(from subject: Subject) -> CDSubject {
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
        return cdSubject
    }
    
    func updateSubject(_ cdSubject: CDSubject, with subject: Subject) {
        cdSubject.name = subject.name
        cdSubject.colorHex = subject.colorHex
        cdSubject.progress = subject.progress
        cdSubject.targetScore = Int32(subject.targetScore)
        cdSubject.icon = subject.icon
        cdSubject.updatedDate = Date()
        
        coreDataManager.saveContext()
    }
    
    func getSubjects() -> [Subject] {
        let cdSubjects = coreDataManager.fetchSubjects()
        return cdSubjects.map { $0.toSubject() }
    }
    
    func getSubject(by id: UUID) -> CDSubject? {
        let request: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try coreDataManager.viewContext.fetch(request).first
        } catch {
            print("Error fetching subject by ID: \(error)")
            return nil
        }
    }
    
    func deleteSubject(_ subject: Subject) {
        guard let cdSubject = getSubject(by: subject.id) else { return }
        coreDataManager.deleteSubject(cdSubject)
    }
    
    // MARK: - Study Session Operations
    func createStudySession(from session: StudySession) -> CDStudySession? {
        guard let subject = getSubject(by: session.subjectId) else { return nil }
        
        let context = coreDataManager.viewContext
        let cdSession = CDStudySession(context: context)
        
        cdSession.id = session.id
        cdSession.date = session.date
        cdSession.durationSeconds = Int32(session.durationSeconds)
        cdSession.isCompleted = session.isCompleted
        cdSession.summary = session.summary
        cdSession.voiceNotePath = session.voiceNotePath
        cdSession.subject = subject
        
        coreDataManager.saveContext()
        return cdSession
    }
    
    func updateStudySession(_ cdSession: CDStudySession, with session: StudySession) {
        cdSession.date = session.date
        cdSession.durationSeconds = Int32(session.durationSeconds)
        cdSession.isCompleted = session.isCompleted
        cdSession.summary = session.summary
        cdSession.voiceNotePath = session.voiceNotePath
        
        coreDataManager.saveContext()
    }
    
    func getStudySessions() -> [StudySession] {
        let cdSessions = coreDataManager.fetchStudySessions()
        return cdSessions.map { $0.toStudySession() }
    }
    
    func getStudySessions(for subjectId: UUID) -> [StudySession] {
        let request: NSFetchRequest<CDStudySession> = CDStudySession.fetchRequest()
        request.predicate = NSPredicate(format: "subject.id == %@", subjectId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDStudySession.date, ascending: false)]
        
        do {
            let cdSessions = try coreDataManager.viewContext.fetch(request)
            return cdSessions.map { $0.toStudySession() }
        } catch {
            print("Error fetching study sessions for subject: \(error)")
            return []
        }
    }
    
    func deleteStudySession(_ session: StudySession) {
        let request: NSFetchRequest<CDStudySession> = CDStudySession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let cdSession = try coreDataManager.viewContext.fetch(request).first {
                coreDataManager.deleteStudySession(cdSession)
            }
        } catch {
            print("Error deleting study session: \(error)")
        }
    }
    

    // MARK: - Result Operations
    func createResult(from result: Result) -> CDResult? {
        guard let subject = getSubject(by: result.subjectId) else { return nil }
        
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
        cdResult.subject = subject
        
        coreDataManager.saveContext()
        
        // Update subject's current score
        updateSubjectMetrics(for: result.subjectId)
        
        return cdResult
    }
    
    func updateResult(_ cdResult: CDResult, with result: Result) {
        let oldSubjectId = cdResult.subject?.id
        
        cdResult.title = result.title
        cdResult.date = result.date
        cdResult.score = Int32(result.score)
        cdResult.maxScore = Int32(result.maxScore)
        cdResult.weight = Int32(result.weight)
        cdResult.category = result.category.rawValue
        cdResult.targetLabel = result.targetLabel
        
        // Update subject reference if changed
        if result.subjectId != oldSubjectId {
            cdResult.subject = getSubject(by: result.subjectId)
        }
        
        coreDataManager.saveContext()
        
        // Update metrics for both old and new subjects
        if let oldSubjectId = oldSubjectId {
            updateSubjectMetrics(for: oldSubjectId)
        }
        updateSubjectMetrics(for: result.subjectId)
    }
    
    func getResults() -> [Result] {
        let cdResults = coreDataManager.fetchResults()
        return cdResults.map { $0.toResult() }
    }
    
    func getResults(for subjectId: UUID) -> [Result] {
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.predicate = NSPredicate(format: "subject.id == %@", subjectId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDResult.date, ascending: false)]
        
        do {
            let cdResults = try coreDataManager.viewContext.fetch(request)
            return cdResults.map { $0.toResult() }
        } catch {
            print("Error fetching results for subject: \(error)")
            return []
        }
    }
    
    func deleteResult(_ result: Result) {
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", result.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let cdResult = try coreDataManager.viewContext.fetch(request).first {
                let subjectId = cdResult.subject?.id
                coreDataManager.deleteResult(cdResult)
                
                // Update subject metrics after deletion
                if let subjectId = subjectId {
                    updateSubjectMetrics(for: subjectId)
                }
            }
        } catch {
            print("Error deleting result: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    private func updateSubjectMetrics(for subjectId: UUID) {
        guard let subject = getSubject(by: subjectId) else { return }
        
        let results = getResults(for: subjectId)
        let currentResult = results.first
        
        let newScore = currentResult?.percentage ?? 0
        subject.progress = Double(min(max(newScore, 0), 100)) / 100.0
        subject.updatedDate = Date()
        
        coreDataManager.saveContext()
    }
    
    // MARK: - Bulk Operations
    func migrateMockData() {
        let mockData = MockData.shared
        
        // Clear existing data
        coreDataManager.deleteAllData()
        
        // Create subjects
        for subject in mockData.subjects {
            _ = createSubject(from: subject)
        }
        
        // Create study sessions
        for session in mockData.recentSessions + mockData.scheduledSessions {
            _ = createStudySession(from: session)
        }
        
        
        // Create results
        for result in mockData.academicResults {
            _ = createResult(from: result)
        }
        
        print("Mock data migration completed")
    }
    
    func isDatabaseEmpty() -> Bool {
        let subjects = coreDataManager.fetchSubjects()
        return subjects.isEmpty
    }
}
