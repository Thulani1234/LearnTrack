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
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    private func encodeToFirestoreData<T: Encodable>(_ data: T) throws -> [String: Any] {
        let encoded = try encoder.encode(data)
        let json = try JSONSerialization.jsonObject(with: encoded, options: [])
        guard let dict = json as? [String: Any] else {
            throw NSError(domain: "FirestoreManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Encoded JSON was not a dictionary"])
        }
        return dict
    }
    
    private func decodeFromFirestoreData<T: Decodable>(_ type: T.Type, data: [String: Any]) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        return try decoder.decode(T.self, from: jsonData)
    }
    
    // Generic Save
    func saveDocument<T: Codable>(collection: String, documentId: String, data: T, completion: @escaping (Error?) -> Void = { _ in }) {
        do {
            let dict = try encodeToFirestoreData(data)
            db.collection(collection).document(documentId).setData(dict, completion: completion)
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
                let data = doc.data()
                return try? self.decodeFromFirestoreData(T.self, data: data)
            } ?? []
            
            completion(documents, nil)
        }
    }
    
    // Specific helpers
    func saveUser(_ user: User, completion: @escaping (Error?) -> Void = { _ in }) {
        saveDocument(collection: "users", documentId: user.id.uuidString, data: user) { error in
            if let error = error {
                print("❌ Firestore write failed: users/\(user.id.uuidString) — \(error)")
            } else {
                print("✅ Firestore write success: users/\(user.id.uuidString)")
            }
            completion(error)
        }
    }

    func saveSubject(_ subject: Subject) {
        saveDocument(collection: "subjects", documentId: subject.id.uuidString, data: subject) { error in
            if let error = error {
                print("❌ Error saving subject: \(error.localizedDescription)")
            } else {
                print("✅ Subject '\(subject.name)' saved to Firestore")
            }
        }
    }
    
    func saveResult(_ result: AcademicResult) {
        saveDocument(collection: "results", documentId: result.id.uuidString, data: result)
    }

    
    func saveNote(_ note: Note) {
        saveDocument(collection: "notes", documentId: note.id.uuidString, data: note)
    }
    
    func saveFCMToken(userId: String, token: String) {
        let data: [String: Any] = [
            "userId": userId,
            "fcmToken": token,
            "updatedAt": Timestamp(date: Date())
        ]
        db.collection("fcmTokens").document(userId).setData(data) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("✅ FCM token saved for user \(userId)")
            }
        }
    }
    
    
    func saveStudySession(_ session: StudySession) {
        saveDocument(collection: "sessions", documentId: session.id.uuidString, data: session)
    }

    func saveVoiceRecording(_ recording: VoiceRecording, completion: @escaping (Error?) -> Void = { _ in }) {
        let dto = VoiceRecordingDTO(from: recording)
        saveDocument(collection: "voiceRecordings", documentId: dto.id, data: dto) { error in
            if let error = error {
                print("❌ Firestore write failed: voiceRecordings/\(dto.id) — \(error)")
            } else {
                print("✅ Firestore write success: voiceRecordings/\(dto.id)")
            }
            completion(error)
        }
    }

    private struct VoiceRecordingDTO: Codable, Hashable {
        var id: String
        var title: String
        var topic: String
        var subjectId: String?
        var duration: String
        var date: String
        var waveform: [Double]
        var audioFileName: String?

        init(from recording: VoiceRecording) {
            self.id = recording.id.uuidString
            self.title = recording.title
            self.topic = recording.topic
            self.subjectId = recording.subjectId?.uuidString
            self.duration = recording.duration
            self.date = recording.date
            self.waveform = recording.waveform.map { Double($0) }
            self.audioFileName = recording.audioURL?.lastPathComponent
        }
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
    
    func deleteResult(_ id: UUID) {
        deleteDocument(collection: "results", documentId: id.uuidString)
    }
}
