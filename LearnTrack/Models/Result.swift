//
//  Result.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation

enum ResultCategory: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case exams = "Exams"
    case projects = "Projects"
    case assignments = "Assignments"
    
    var id: String { rawValue }
}

struct Result: Identifiable, Hashable {
    var id = UUID()
    var subjectId: UUID
    var title: String
    var date: Date
    var score: Int
    var maxScore: Int
    var weight: Int
    var category: ResultCategory
    var targetLabel: String
    
    var percentage: Int {
        guard maxScore > 0 else { return 0 }
        return Int((Double(score) / Double(maxScore)) * 100)
    }
    
    var grade: String {
        switch percentage {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B+"
        case 60..<70: return "C"
        default: return "D"
        }
    }
    
    var targetStatus: String {
        percentage >= targetScore ? "Target achieved!" : "\(targetScore - percentage)% below target"
    }
    
    var targetScore: Int {
        switch targetLabel {
        case "A+": return 95
        case "A": return 90
        case "B+": return 85
        case "B": return 80
        case "C+": return 75
        case "C": return 70
        default: return 60
        }
    }
}

