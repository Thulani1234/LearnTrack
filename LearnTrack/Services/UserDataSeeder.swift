//
//  UserDataSeeder.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

class UserDataSeeder {
    static let shared = UserDataSeeder()
    private let coreDataManager = CoreDataManager.shared
    private let authService = AuthenticationService.shared
    
    private init() {}
    
    // MARK: - Public Methods
    func seedSampleUsers() {
        print("Seeding sample users to database...")
        
        let sampleUsers = generateSampleUsers()
        
        for userData in sampleUsers {
            let result = authService.registerUser(
                name: userData.name,
                email: userData.email,
                phoneNumber: userData.phoneNumber,
                password: userData.password
            )
            
            if let user = result.user {
                print("✅ User created: \(user.name) (\(user.email))")
            } else if let error = result.error {
                print("❌ Failed to create user: \(userData.email) - \(error.localizedDescription)")
            }
        }
        
        print("User data seeding completed")
    }
    
    func clearAllUsers() {
        print("Clearing all users...")
        
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            coreDataManager.saveContext()
            print("All users cleared: \(users.count) users deleted")
        } catch {
            print("Failed to clear users: \(error)")
        }
    }
    
    func regenerateUsers() {
        print("Regenerating users...")
        clearAllUsers()
        seedSampleUsers()
        print("User regeneration completed")
    }
    
    // MARK: - Private Methods
    private func generateSampleUsers() -> [(name: String, email: String, phoneNumber: String, password: String)] {
        return [
            (
                name: "John Smith",
                email: "john.smith@learntrack.com",
                phoneNumber: "+1234567890",
                password: "password123"
            ),
            (
                name: "Sarah Johnson",
                email: "sarah.johnson@learntrack.com",
                phoneNumber: "+1234567891",
                password: "password123"
            ),
            (
                name: "Michael Brown",
                email: "michael.brown@learntrack.com",
                phoneNumber: "+1234567892",
                password: "password123"
            ),
            (
                name: "Emily Davis",
                email: "emily.davis@learntrack.com",
                phoneNumber: "+1234567893",
                password: "password123"
            ),
            (
                name: "David Wilson",
                email: "david.wilson@learntrack.com",
                phoneNumber: "+1234567894",
                password: "password123"
            )
        ]
    }
}
