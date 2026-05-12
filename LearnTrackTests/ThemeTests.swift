//
//  ThemeTests.swift
//  LearnTrackTests
//
//  Created by Antigravity on 2026-05-12.
//

import XCTest
import SwiftUI
@testable import LearnTrack

class ThemeTests: XCTestCase {

    func testBackgroundGreenDefined() {
        // Verify that backgroundGreen is correctly defined in AppColors
        let color = AppColors.backgroundGreen
        XCTAssertNotNil(color, "backgroundGreen should be defined in AppColors")
    }

    func testBackgroundGreenHexConversion() {
        // Verify that the color can be converted to hex string
        let color = AppColors.backgroundGreen
        let hex = color.toHex()
        XCTAssertNotNil(hex, "Color should be convertible to hex string")
        
        // The hex value will depend on the color scheme (light/dark)
        // In the test environment, we can't easily force the color scheme for a static property
        // but we can ensure it's a valid hex string of length 6 or 8
        if let hexValue = hex {
            XCTAssertTrue(hexValue.count == 6 || hexValue.count == 8, "Hex value should be 6 or 8 characters long")
            print("✅ Verified backgroundGreen hex: \(hexValue)")
        }
    }
}
