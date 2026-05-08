//
//  Typography.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct AppTypography {
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title = Font.system(size: 22, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 11, weight: .medium, design: .rounded)
    
    // Dynamic Type versions using iOS text styles
    static let dynamicTitleLarge = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let dynamicTitle = Font.system(.title, design: .rounded).weight(.bold)
    static let dynamicHeadline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let dynamicBody = Font.system(.body, design: .rounded)
    static let dynamicBodySmall = Font.system(.subheadline, design: .rounded)
    static let dynamicCaption = Font.system(.caption, design: .rounded).weight(.medium)
}

extension View {
    @ViewBuilder
    func applyDynamicType(_ isEnabled: Bool) -> some View {
        if isEnabled {
            self.dynamicTypeSize(.accessibility1 ... .accessibility5)
        } else {
            self
        }
    }
}

