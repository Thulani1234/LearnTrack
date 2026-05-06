//
//  AuthenticationServiceTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class AuthenticationServiceTests: XCTestCase {

    var authService: AuthenticationService!

    override func setUp() {
        super.setUp()
        authService = AuthenticationService.shared
    }

    override func tearDown() {
        authService = nil
        super.tearDown()
    }

    // MARK: - OTP Generation Tests

    func testGenerateOTP_ReturnsSixDigitString() {
        let otp = authService.generateOTP(for: "+1234567890")
        XCTAssertEqual(otp.count, 6)
        XCTAssertTrue(otp.allSatisfy { $0.isNumber })
    }

    func testGenerateOTPForEmail_ReturnsSixDigitString() {
        let otp = authService.generateOTPForEmail("test@example.com")
        XCTAssertEqual(otp.count, 6)
        XCTAssertTrue(otp.allSatisfy { $0.isNumber })
    }

    func testValidateOTP_ValidOTP_ReturnsTrue() {
        let validOTP = "123456"
        XCTAssertTrue(authService.validateOTP(otp: validOTP, phoneNumber: "+1234567890"))
    }

    func testValidateOTP_InvalidLength_ReturnsFalse() {
        let invalidOTP = "12345" // 5 digits
        XCTAssertFalse(authService.validateOTP(otp: invalidOTP, phoneNumber: "+1234567890"))
    }

    func testValidateOTP_WithLetters_ReturnsFalse() {
        let invalidOTP = "12345A" // Contains letter
        XCTAssertFalse(authService.validateOTP(otp: invalidOTP, phoneNumber: "+1234567890"))
    }

    func testValidateOTP_EmptyOTP_ReturnsFalse() {
        let invalidOTP = ""
        XCTAssertFalse(authService.validateOTP(otp: invalidOTP, phoneNumber: "+1234567890"))
    }

    // MARK: - Authentication Error Tests

    func testAuthenticationError_ValidationError_Description() {
        let errors = ["Name is required", "Email is invalid"]
        let error = AuthenticationError.validationError(errors)
        XCTAssertEqual(error.errorDescription, "Name is required, Email is invalid")
    }

    func testAuthenticationError_EmailAlreadyExists_Description() {
        let error = AuthenticationError.emailAlreadyExists
        XCTAssertEqual(error.errorDescription, "An account with this email already exists")
    }

    func testAuthenticationError_PhoneNumberAlreadyExists_Description() {
        let error = AuthenticationError.phoneNumberAlreadyExists
        XCTAssertEqual(error.errorDescription, "An account with this phone number already exists")
    }

    func testAuthenticationError_RegistrationFailed_Description() {
        let error = AuthenticationError.registrationFailed
        XCTAssertEqual(error.errorDescription, "Registration failed. Please try again")
    }

    func testAuthenticationError_UserNotFound_Description() {
        let error = AuthenticationError.userNotFound
        XCTAssertEqual(error.errorDescription, "User not found")
    }

    func testAuthenticationError_InvalidCredentials_Description() {
        let error = AuthenticationError.invalidCredentials
        XCTAssertEqual(error.errorDescription, "Invalid email or password")
    }

    func testAuthenticationError_OtpInvalid_Description() {
        let error = AuthenticationError.otpInvalid
        XCTAssertEqual(error.errorDescription, "Invalid OTP code")
    }

    func testAuthenticationError_OtpExpired_Description() {
        let error = AuthenticationError.otpExpired
        XCTAssertEqual(error.errorDescription, "OTP code has expired")
    }

    // MARK: - User Validation Tests (Integration with User model)

    func testRegisterUser_ValidUser_ReturnsUser() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "john.doe@example.com",
            phoneNumber: "1234567890",
            password: "password123",
            address: "123 Main St",
            country: "USA"
        )

        XCTAssertNotNil(result.user)
        XCTAssertNil(result.error)
        XCTAssertEqual(result.user?.name, "John Doe")
        XCTAssertEqual(result.user?.email, "john.doe@example.com")
        XCTAssertEqual(result.user?.phoneNumber, "1234567890")
        XCTAssertEqual(result.user?.address, "123 Main St")
        XCTAssertEqual(result.user?.country, "USA")
    }

    func testRegisterUser_InvalidName_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "J", // Too short
            email: "john@example.com",
            phoneNumber: "1234567890",
            password: "password123"
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Name must be between 2 and 50 characters") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_InvalidEmail_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "invalid-email", // Invalid email
            phoneNumber: "1234567890",
            password: "password123"
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Please enter a valid email address") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_InvalidPhone_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "john@example.com",
            phoneNumber: "123-456-789", // Invalid phone format
            password: "password123"
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Please enter a valid phone number") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_InvalidPassword_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "john@example.com",
            phoneNumber: "1234567890",
            password: "pass" // Too short
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Password must be at least 8 characters long") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_EmptyAddress_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "john@example.com",
            phoneNumber: "1234567890",
            password: "password123",
            address: "", // Empty address
            country: "USA"
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Please enter your address") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_EmptyCountry_ReturnsValidationError() {
        let result = authService.registerUser(
            name: "John Doe",
            email: "john@example.com",
            phoneNumber: "1234567890",
            password: "password123",
            address: "123 Main St",
            country: "" // Empty country
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertTrue(errors.contains { $0.contains("Please select your country") })
        } else {
            XCTFail("Expected validation error")
        }
    }

    func testRegisterUser_MultipleValidationErrors_ReturnsAllErrors() {
        let result = authService.registerUser(
            name: "J", // Too short
            email: "invalid-email", // Invalid
            phoneNumber: "123-456-789", // Invalid format
            password: "pass", // Too short
            address: "", // Empty
            country: "" // Empty
        )

        XCTAssertNil(result.user)
        XCTAssertNotNil(result.error)

        if case .validationError(let errors) = result.error {
            XCTAssertEqual(errors.count, 6) // All validation errors
        } else {
            XCTFail("Expected validation error")
        }
    }
}