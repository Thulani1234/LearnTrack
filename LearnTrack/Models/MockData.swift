//
//  MockData.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class MockData: ObservableObject {
    static let shared = MockData()
    
    @Published var subjects: [Subject] = []
    @Published var recentSessions: [StudySession] = []
    @Published var scheduledSessions: [StudySession] = []
    @Published var academicResults: [AcademicResult] = []
    @Published var notes: [Note] = []
    @Published var voiceRecordings: [VoiceRecording] = []
    
    private let firestore = FirestoreManager.shared
    private let coreData = CoreDataManager.shared
    private var currentUserId: UUID?
    private var voiceRecordingsByUser: [UUID: [VoiceRecording]] = [:]
    
    private init() {
        loadInitialData()
    }
    
    func configure(for user: User) {
        currentUserId = user.id
        mapCoreDataToState()
        voiceRecordings = voiceRecordingsByUser[user.id] ?? []
    }
    
    func resetForSignedOutUser() {
        currentUserId = nil
        subjects = []
        recentSessions = []
        scheduledSessions = []
        academicResults = []
        notes = []
        voiceRecordings = []
    }
    
    func loadInitialData() {
        guard currentUserId != nil else {
            resetForSignedOutUser()
            return
        }
        
        mapCoreDataToState()
    }
    
    private func seedInitialData() {
        let initialSubjects = [
            Subject(name: "Mathematics", colorHex: "6366F1", progress: 0.7, targetScore: 95, currentScore: 89, icon: "function"),
            Subject(name: "Science", colorHex: "14B8A6", progress: 0.4, targetScore: 90, currentScore: 75, icon: "flask.fill"),
            Subject(name: "English", colorHex: "F59E0B", progress: 0.9, targetScore: 85, currentScore: 82, icon: "book.fill"),
            Subject(name: "ICT", colorHex: "A855F7", progress: 0.6, targetScore: 100, currentScore: 92, icon: "laptopcomputer")
        ]
        
        subjects = initialSubjects
        
        // Sync these to databases
        for subject in subjects {
            saveSubject(subject)
        }
        
        recentSessions = [
            StudySession(subjectId: subjects[0].id, date: Date(), durationSeconds: 45 * 60, isCompleted: true, summary: "Completed algebra practice."),
            StudySession(subjectId: subjects[1].id, date: Date().addingTimeInterval(-86400), durationSeconds: 30 * 60, isCompleted: true, summary: "Read chapter 3 of biology.")
        ]
        
        for session in recentSessions {
            saveStudySession(session)
        }
        
        academicResults = [
            AcademicResult(subjectId: subjects[1].id, title: "Mid-term Exam", date: Date().addingTimeInterval(-86400 * 4), score: 78, maxScore: 100, weight: 30, category: .exams, targetLabel: "A"),
            AcademicResult(subjectId: subjects[3].id, title: "Data Structures Project", date: Date().addingTimeInterval(-86400 * 7), score: 85, maxScore: 100, weight: 30, category: .classTests, targetLabel: "A")
        ]
        
        for result in academicResults {
            saveResult(result)
        }
        
        notes = [
            Note(title: "Physics Formulas", content: "F=ma, E=mc^2, v=u+at. Important for the upcoming semester finals...", colorHex: "3B82F6", category: "Physics", dateCreated: Date(), attachedFileNames: []),
            Note(title: "Reaction Mechanisms", content: "Organic chemistry reaction mechanisms. Remember to focus on nucleophilic...", colorHex: "A855F7", category: "Chemistry", dateCreated: Date(), attachedFileNames: [])
        ]
        
        for note in notes {
            addNote(note)
        }
    }
    
    private func mapCoreDataToState() {
        guard let currentUserId else {
            resetForSignedOutUser()
            return
        }
        
        let cdSubjects = coreData.fetchSubjects(for: currentUserId)
        self.subjects = cdSubjects.map { cd in
            Subject(
                id: cd.id ?? UUID(),
                name: cd.name ?? "Unknown",
                colorHex: cd.colorHex ?? "6366F1",
                progress: cd.progress,
                targetScore: Int(cd.targetScore),
                currentScore: Int(cd.progress * 100), // Approximation
                icon: cd.icon ?? "book.fill"
            )
        }
        
        let cdResults = coreData.fetchResults(for: currentUserId)
        self.academicResults = cdResults.map { cd in
            AcademicResult(
                id: cd.id ?? UUID(),
                subjectId: cd.subject?.id ?? UUID(),
                title: cd.title ?? "Result",
                date: cd.date ?? Date(),
                score: Int(cd.score),
                maxScore: Int(cd.maxScore),
                weight: Int(cd.weight),
                category: ResultCategory(rawValue: cd.category ?? "Exams") ?? .exams,
                targetLabel: cd.targetLabel ?? "A"
            )
        }
        
        let cdSessions = coreData.fetchStudySessions(for: currentUserId)
        self.recentSessions = cdSessions.map { cd in
            StudySession(
                id: cd.id ?? UUID(),
                subjectId: cd.subject?.id ?? UUID(),
                date: cd.date ?? Date(),
                durationSeconds: Int(cd.durationSeconds),
                isCompleted: cd.isCompleted,
                summary: cd.summary,
                voiceNotePath: cd.voiceNotePath
            )
        }
    }
    
    // MARK: - Save Methods
    
    func addSubject(_ subject: Subject) {
        subjects.append(subject)
        saveSubject(subject)
    }
    
    func deleteSubject(_ subject: Subject) {
        subjects.removeAll { $0.id == subject.id }
        
        // Remove from CoreData
        let context = coreData.viewContext
        let cdSubjects = currentUserId.map { coreData.fetchSubjects(for: $0) } ?? []
        if let cdSubject = cdSubjects.first(where: { $0.id == subject.id }) {
            context.delete(cdSubject)
            coreData.saveContext()
        }
        
        // Remove from Firestore
        firestore.deleteSubject(subject.id)
    }
    
    private func saveSubject(_ subject: Subject) {
        // Save to Firestore
        firestore.saveSubject(subject)
        
        // Save to CoreData
        let context = coreData.viewContext
        let cdSubject = CDSubject(context: context)
        cdSubject.id = subject.id
        cdSubject.name = subject.name
        cdSubject.colorHex = subject.colorHex
        cdSubject.progress = subject.progress
        cdSubject.targetScore = Int32(subject.targetScore)
        cdSubject.icon = subject.icon
        cdSubject.createdDate = Date()
        cdSubject.updatedDate = Date()
        if let currentUserId {
            cdSubject.user = coreData.fetchUser(by: currentUserId)
        }
        coreData.saveContext()
    }
    
    func addResult(title: String, subjectId: UUID, score: Int, maxScore: Int, weight: Int, category: ResultCategory, targetLabel: String, date: Date = Date()) {
        let result = AcademicResult(
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
        saveResult(result)
        updateSubjectMetrics(for: subjectId)
    }
    
    private func saveResult(_ result: AcademicResult) {
        firestore.saveResult(result)
        
        let context = coreData.viewContext
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", result.id as CVarArg)
        request.fetchLimit = 1
        let cdResult = (try? context.fetch(request).first) ?? CDResult(context: context)
        cdResult.id = result.id
        cdResult.title = result.title
        cdResult.date = result.date
        cdResult.score = Int32(result.score)
        cdResult.maxScore = Int32(result.maxScore)
        cdResult.weight = Int32(result.weight)
        cdResult.category = result.category.rawValue
        cdResult.targetLabel = result.targetLabel
        
        // Link to subject
        let cdSubjects = currentUserId.map { coreData.fetchSubjects(for: $0) } ?? []
        if let cdSubject = cdSubjects.first(where: { $0.id == result.subjectId }) {
            cdResult.subject = cdSubject
        }
        
        coreData.saveContext()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        firestore.saveNote(note)
        // Note: I'd need to add CDNote to CoreData model if I want local persistence for notes
    }
    
    func addStudySession(subjectId: UUID, durationSeconds: Int, summary: String? = nil) {
        let session = StudySession(
            subjectId: subjectId,
            date: Date(),
            durationSeconds: durationSeconds,
            isCompleted: true,
            summary: summary
        )
        recentSessions.append(session)
        saveStudySession(session)
    }
    
    func addVoiceRecording(_ recording: VoiceRecording) {
        voiceRecordings.insert(recording, at: 0)
        if let currentUserId {
            voiceRecordingsByUser[currentUserId] = voiceRecordings
        }
        firestore.saveVoiceRecording(recording)
    }
    
    private func saveStudySession(_ session: StudySession) {
        firestore.saveStudySession(session)
        
        let context = coreData.viewContext
        let cdSession = CDStudySession(context: context)
        cdSession.id = session.id
        cdSession.date = session.date
        cdSession.durationSeconds = Int32(session.durationSeconds)
        cdSession.isCompleted = session.isCompleted
        cdSession.summary = session.summary
        
        let cdSubjects = currentUserId.map { coreData.fetchSubjects(for: $0) } ?? []
        if let cdSubject = cdSubjects.first(where: { $0.id == session.subjectId }) {
            cdSession.subject = cdSubject
        }
        
        coreData.saveContext()
    }
    
    func updateResult(_ updatedResult: AcademicResult) {
        guard let index = academicResults.firstIndex(where: { $0.id == updatedResult.id }) else { return }
        let oldSubjectId = academicResults[index].subjectId
        academicResults[index] = updatedResult
        saveResult(updatedResult)
        updateSubjectMetrics(for: oldSubjectId)
        updateSubjectMetrics(for: updatedResult.subjectId)
    }
    
    func deleteResult(_ result: AcademicResult) {
        academicResults.removeAll { $0.id == result.id }
        
        let context = coreData.viewContext
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", result.id as CVarArg)
        request.fetchLimit = 1
        
        if let cdResult = try? context.fetch(request).first {
            context.delete(cdResult)
            coreData.saveContext()
        }
        
        firestore.deleteResult(result.id)
        updateSubjectMetrics(for: result.subjectId)
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
        
        // Update CoreData
        let cdSubjects = currentUserId.map { coreData.fetchSubjects(for: $0) } ?? []
        if let cdSubject = cdSubjects.first(where: { $0.id == subjectId }) {
            cdSubject.progress = subjects[index].progress
            coreData.saveContext()
        }
    }
    
    // Type aliases for AppRouter
    typealias SubjectMock = Subject
}
