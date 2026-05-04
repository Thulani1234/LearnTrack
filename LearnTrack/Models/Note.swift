//
//  Note.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var colorHex: String
    var category: String
    var dateCreated: Date
    var attachedFileNames: [String]
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: dateCreated)
    }
}
