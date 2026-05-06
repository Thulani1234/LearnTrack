//
//  AuthenticationService.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import CoreData

class AuthenticationService {
    static let shared = AuthenticationService()
    private let coreDataManager = CoreDataManager.shared
    private let firestore = FirestoreManager.shared
    
    private init() {}
    
    // MARK: - User Registration
    func registerUser(name: String, email: String, phoneNumber: String, password: String, address: String = "", country: String = "") -> (user: User?, error: AuthenticationError?) {
        let user = User(name: name, email: email, phoneNumber: phoneNumber, password: password, address: address, country: country)
        
        // Validate user data
        let validation = user.validateAll()
        if !validation.isValid {
            return (nil, .validationError(validation.errors))
        }
        
        // Note: Removed email and phone uniqueness checks to allow multiple accounts
        // Users can have same email or phone number for different accounts
        
        // Create user in Core Data
        let success = createUserInCoreData(user: user)
        if success {
            firestore.saveUser(user) { error in
                if let error = error {
                    print("❌ Error saving user to Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ User '\(user.name)' saved to Firestore")
                }
            }
            return (user, nil)
        } else {
            return (nil, .registrationFailed)
        }
    }
    
    // MARK: - User Login
    func loginUser(email: String, password: String) -> (user: User?, error: AuthenticationError?) {
        guard let cdUser = fetchUserByEmail(email) else {
            return (nil, .userNotFound)
        }
        
        // In production, this should use proper password hashing
        if cdUser.password != password {
            return (nil, .invalidCredentials)
        }
        
        let user = User(
            id: cdUser.id ?? UUID(),
            name: cdUser.name ?? "",
            email: cdUser.email ?? "",
            phoneNumber: cdUser.phoneNumber ?? "",
            password: cdUser.password ?? "",
            address: cdUser.address ?? "",
            country: cdUser.country ?? "",
            isEmailVerified: cdUser.isEmailVerified,
            isPhoneVerified: cdUser.isPhoneVerified,
            profileImageURL: cdUser.profileImageURL,
            createdAt: cdUser.createdAt ?? Date(),
            updatedAt: cdUser.updatedAt ?? Date()
        )

        firestore.saveUser(user) { error in
            if let error = error {
                print("❌ Error syncing user to Firestore on login: \(error.localizedDescription)")
            } else {
                print("✅ User '\(user.name)' synced to Firestore on login")
            }
        }
        
        // Save current user ID for FCM token association
        UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
        
        return (user, nil)
    }
    
    // MARK: - OTP Generation and Validation
    func generateOTP(for phoneNumber: String) -> String {
        // Generate 6-digit OTP
        let otp = String(format: "%06d", Int.random(in: 100000...999999))
        
        // Send OTP via SMS
        SMSService.shared.sendOTP(otp: otp, to: phoneNumber) { success, error in
            if success {
                print("✅ OTP sent successfully to \(phoneNumber)")
            } else {
                print("❌ Failed to send OTP: \(error ?? "Unknown error")")
            }
        }
        
        return otp
    }
    
    func generateOTPForEmail(email: String) -> String {
        // Generate 6-digit OTP
        let otp = String(format: "%06d", Int.random(in: 100000...999999))
        
        // Send OTP via Email
        SMSService.shared.sendOTPToEmail(otp: otp, to: email) { success, error in
            if success {
                print("✅ OTP sent successfully to \(email)")
            } else {
                print("❌ Failed to send OTP: \(error ?? "Unknown error")")
            }
        }
        
        return otp
    }
    
    func validateOTP(otp: String, phoneNumber: String) -> Bool {
        // In production, this would validate against stored OTP
        // For now, we'll accept any 6-digit number as valid for testing
        return otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }
    
    func verifyUserPhone(phoneNumber: String) -> Bool {
        guard let cdUser = fetchUserByPhoneNumber(phoneNumber) else {
            return false
        }
        
        cdUser.isPhoneVerified = true
        cdUser.updatedAt = Date()
        coreDataManager.saveContext()
        
        return true
    }
    
    func verifyUserEmail(email: String) -> Bool {
        guard let cdUser = fetchUserByEmail(email) else {
            return false
        }
        
        cdUser.isEmailVerified = true
        cdUser.updatedAt = Date()
        coreDataManager.saveContext()
        
        return true
    }
    
    // MARK: - User Management
    func updateUserProfile(
        userId: UUID,
        name: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        address: String? = nil,
        country: String? = nil,
        profileImageURL: String? = nil
    ) -> Bool {
        guard let cdUser = fetchUserById(userId) else {
            return false
        }
        
        if let name = name {
            cdUser.name = name
        }

        if let email = email {
            cdUser.email = email
        }

        if let phoneNumber = phoneNumber {
            cdUser.phoneNumber = phoneNumber
        }
        
        if let address = address {
            cdUser.address = address
        }
        
        if let country = country {
            cdUser.country = country
        }
        
        if let profileImageURL = profileImageURL {
            cdUser.profileImageURL = profileImageURL
        }
        
        cdUser.updatedAt = Date()
        coreDataManager.saveContext()

        let updatedUser = User(
            id: cdUser.id ?? userId,
            name: cdUser.name ?? "",
            email: cdUser.email ?? "",
            phoneNumber: cdUser.phoneNumber ?? "",
            password: cdUser.password ?? "",
            address: cdUser.address ?? "",
            country: cdUser.country ?? "",
            isEmailVerified: cdUser.isEmailVerified,
            isPhoneVerified: cdUser.isPhoneVerified,
            profileImageURL: cdUser.profileImageURL,
            createdAt: cdUser.createdAt ?? Date(),
            updatedAt: cdUser.updatedAt ?? Date()
        )
        firestore.saveUser(updatedUser) { error in
            if let error = error {
                print("❌ Error syncing updated user to Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Updated user '\(updatedUser.name)' synced to Firestore")
            }
        }
        
        return true
    }
    
    func deleteUser(userId: UUID) -> Bool {
        guard let cdUser = fetchUserById(userId) else {
            return false
        }
        
        let context = coreDataManager.viewContext
        context.delete(cdUser)
        coreDataManager.saveContext()
        
        return true
    }
    
    // MARK: - Private Methods
    private func checkUserExists(email: String) -> Bool {
        return fetchUserByEmail(email) != nil
    }
    
    private func checkUserExists(phoneNumber: String) -> Bool {
        return fetchUserByPhoneNumber(phoneNumber) != nil
    }
    
    private func createUserInCoreData(user: User) -> Bool {
        let context = coreDataManager.viewContext
        let cdUser = CDUser(context: context)
        
        cdUser.id = user.id
        cdUser.name = user.name
        cdUser.email = user.email
        cdUser.phoneNumber = user.phoneNumber
        cdUser.password = user.password // In production, hash this
        cdUser.isEmailVerified = user.isEmailVerified
        cdUser.isPhoneVerified = user.isPhoneVerified
        cdUser.profileImageURL = user.profileImageURL
        cdUser.createdAt = user.createdAt
        cdUser.updatedAt = user.updatedAt
        
        cdUser.address = user.address
        cdUser.country = user.country
        
        do {
            try context.save()
            print("✅ User saved to Core Data: \(user.name) (\(user.email))")
            return true
        } catch {
            print("❌ Failed to save user to Core Data: \(error)")
            context.rollback()
            return false
        }
    }
    
    private func fetchUserByEmail(_ email: String) -> CDUser? {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user by email: \(error)")
            return nil
        }
    }
    
    private func fetchUserByPhoneNumber(_ phoneNumber: String) -> CDUser? {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user by phone number: \(error)")
            return nil
        }
    }
    
    private func fetchUserById(_ id: UUID) -> CDUser? {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user by ID: \(error)")
            return nil
        }
    }
}

// MARK: - Authentication Error Types
enum AuthenticationError: LocalizedError {
    case validationError([String])
    case emailAlreadyExists
    case phoneNumberAlreadyExists
    case registrationFailed
    case userNotFound
    case invalidCredentials
    case otpInvalid
    case otpExpired
    
    var errorDescription: String? {
        switch self {
        case .validationError(let errors):
            return errors.joined(separator: ", ")
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .phoneNumberAlreadyExists:
            return "An account with this phone number already exists"
        case .registrationFailed:
            return "Registration failed. Please try again"
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .otpInvalid:
            return "Invalid OTP code"
        case .otpExpired:
            return "OTP code has expired"
        }
    }
}
