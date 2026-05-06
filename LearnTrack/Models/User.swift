//
//  User.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phoneNumber: String
    var password: String // In production, this should be hashed
    var isEmailVerified: Bool
    var isPhoneVerified: Bool
    var address: String
    var country: String
    var profileImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, email: String, phoneNumber: String, password: String, address: String = "", country: String = "", isEmailVerified: Bool = false, isPhoneVerified: Bool = false, profileImageURL: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.address = address
        self.country = country
        self.isEmailVerified = isEmailVerified
        self.isPhoneVerified = isPhoneVerified
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Validation methods
    func validateName() -> Bool {
        return name.count >= 2 && name.count <= 50
    }
    
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePhoneNumber() -> Bool {
        let phoneRegex = "^[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
    }
    
    func validatePassword() -> Bool {
        return password.count >= 8
    }
    
    func validateAddress() -> Bool {
        return !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validateCountry() -> Bool {
        return !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validateAll() -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        if !validateName() {
            errors.append("Name must be between 2 and 50 characters")
        }
        
        if !validateEmail() {
            errors.append("Please enter a valid email address")
        }
        
        if !validatePhoneNumber() {
            errors.append("Please enter a valid phone number")
        }
        
        if !validatePassword() {
            errors.append("Password must be at least 8 characters long")
        }
        
        if !validateAddress() {
            errors.append("Please enter your address")
        }
        
        if !validateCountry() {
            errors.append("Please select your country")
        }
        
        return (errors.isEmpty, errors)
    }
}
