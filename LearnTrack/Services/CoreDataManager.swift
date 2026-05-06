//
//  CoreDataManager.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData
import Combine

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "LearnTrack")
        
        // Load persistent stores
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
                // In production, you might want to handle this more gracefully
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Configure contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func getBackgroundContext() -> NSManagedObjectContext {
        return backgroundContext
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveBackgroundContext(_ context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    print("Core Data background save error: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    // MARK: - Fetch Methods
    func fetchSubjects() -> [CDSubject] {
        let request: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSubject.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching subjects: \(error)")
            return []
        }
    }
    
    func fetchSubjects(for userId: UUID) -> [CDSubject] {
        let request: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDSubject.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching subjects for user: \(error)")
            return []
        }
    }
    
    func fetchStudySessions() -> [CDStudySession] {
        let request: NSFetchRequest<CDStudySession> = CDStudySession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDStudySession.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching study sessions: \(error)")
            return []
        }
    }
    
    func fetchStudySessions(for userId: UUID) -> [CDStudySession] {
        let request: NSFetchRequest<CDStudySession> = CDStudySession.fetchRequest()
        request.predicate = NSPredicate(format: "subject.user.id == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDStudySession.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching study sessions for user: \(error)")
            return []
        }
    }
    
    
    func fetchResults() -> [CDResult] {
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDResult.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching results: \(error)")
            return []
        }
    }
    
    func fetchResults(for userId: UUID) -> [CDResult] {
        let request: NSFetchRequest<CDResult> = CDResult.fetchRequest()
        request.predicate = NSPredicate(format: "subject.user.id == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDResult.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching results for user: \(error)")
            return []
        }
    }
    
    func fetchUser(by id: UUID) -> CDUser? {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching user by ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Delete Methods
    func deleteSubject(_ subject: CDSubject) {
        viewContext.delete(subject)
        saveContext()
    }
    
    func deleteStudySession(_ session: CDStudySession) {
        viewContext.delete(session)
        saveContext()
    }
    
    
    func deleteResult(_ result: CDResult) {
        viewContext.delete(result)
        saveContext()
    }
    
    // MARK: - Utility Methods
    func deleteAllData() {
        let entities = ["CDSubject", "CDStudySession", "CDResult"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(deleteRequest)
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        
        saveContext()
    }
}
