//
//  CoreDataManager.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // For this UI phase, we just stub the container to prevent compilation errors if referenced.
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "LearnTrack")
        // container.loadPersistentStores { ... }
    }
    
    func saveContext() {
        // let context = container.viewContext
        // if context.hasChanges { try? context.save() }
    }
}

