//
//  FirestoreManager.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Generic Save
    func saveDocument<T: Codable>(collection: String, documentId: String, data: T, completion: @escaping (Error?) -> Void = { _ in }) {
        do {
            try db.collection(collection).document(documentId).setData(from: data, completion: completion)
        } catch {
            print("❌ Firestore encoding error: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    // Generic Fetch
    func fetchDocuments<T: Codable>(collection: String, completion: @escaping ([T], Error?) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion([], error)
                return
            }
            
            let documents = snapshot?.documents.compactMap { doc -> T? in
                try? doc.data(as: T.self)
            } ?? []
            
            completion(documents, nil)
        }
    }
    
    // Specific helpers
    func saveSubject(_ subject: Subject) {
        saveDocument(collection: "subjects", documentId: subject.id.uuidString, data: subject) { error in
            if let error = error {
                print("❌ Error saving subject: \(error.localizedDescription)")
            } else {
                print("✅ Subject '\(subject.name)' saved to Firestore")
            }
        }
    }
    
    func saveResult(_ result: Result) {
        saveDocument(collection: "results", documentId: result.id.uuidString, data: result)
    }
    
    func saveNote(_ note: Note) {
        saveDocument(collection: "notes", documentId: note.id.uuidString, data: note)
    }
    
    
    func saveStudySession(_ session: StudySession) {
        saveDocument(collection: "sessions", documentId: session.id.uuidString, data: session)
    }
    
    // Deletion
    func deleteDocument(collection: String, documentId: String) {
        db.collection(collection).document(documentId).delete { error in
            if let error = error {
                print("❌ Firestore deletion error: \(error.localizedDescription)")
            } else {
                print("🗑️ Document \(documentId) deleted from \(collection)")
            }
        }
    }
    
    func deleteSubject(_ id: UUID) {
        deleteDocument(collection: "subjects", documentId: id.uuidString)
    }
}
