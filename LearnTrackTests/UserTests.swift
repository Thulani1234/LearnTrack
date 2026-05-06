//
//  UserTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class UserTests: XCTestCase {

    func testValidateName_ValidName_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validateName())
    }

    func testValidateName_NameTooShort_ReturnsFalse() {
        let user = User(name: "J", email: "john@example.com", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertFalse(user.validateName())
    }

    func testValidateName_NameTooLong_ReturnsFalse() {
        let longName = String(repeating: "A", count: 51)
        let user = User(name: longName, email: "john@example.com", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertFalse(user.validateName())
    }

    func testValidateEmail_ValidEmail_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john.doe@example.com", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validateEmail())
    }

    func testValidateEmail_InvalidEmail_ReturnsFalse() {
        let user = User(name: "John Doe", email: "invalid-email", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertFalse(user.validateEmail())
    }

    func testValidatePhoneNumber_ValidPhone_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validatePhoneNumber())
    }

    func testValidatePhoneNumber_InvalidPhone_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "123-456-789", password: "password", address: "123 Main St", country: "USA")
        XCTAssertFalse(user.validatePhoneNumber())
    }

    func testValidatePhoneNumber_PhoneWithSpaces_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "123 456 7890", password: "password", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validatePhoneNumber())
    }

    func testValidatePassword_ValidPassword_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validatePassword())
    }

    func testValidatePassword_InvalidPassword_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "pass", address: "123 Main St", country: "USA")
        XCTAssertFalse(user.validatePassword())
    }

    func testValidateAddress_ValidAddress_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validateAddress())
    }

    func testValidateAddress_EmptyAddress_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "", country: "USA")
        XCTAssertFalse(user.validateAddress())
    }

    func testValidateAddress_WhitespaceAddress_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "   ", country: "USA")
        XCTAssertFalse(user.validateAddress())
    }

    func testValidateCountry_ValidCountry_ReturnsTrue() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "USA")
        XCTAssertTrue(user.validateCountry())
    }

    func testValidateCountry_EmptyCountry_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "")
        XCTAssertFalse(user.validateCountry())
    }

    func testValidateCountry_WhitespaceCountry_ReturnsFalse() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "   ")
        XCTAssertFalse(user.validateCountry())
    }

    func testValidateAll_ValidUser_ReturnsValid() {
        let user = User(name: "John Doe", email: "john@example.com", phoneNumber: "1234567890", password: "password123", address: "123 Main St", country: "USA")
        let validation = user.validateAll()
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.errors.isEmpty)
    }

    func testValidateAll_InvalidUser_ReturnsErrors() {
        let user = User(name: "J", email: "invalid", phoneNumber: "123", password: "pass", address: "", country: "")
        let validation = user.validateAll()
        XCTAssertFalse(validation.isValid)
        XCTAssertEqual(validation.errors.count, 6)
    }
}