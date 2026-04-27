//
//  Subject.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation

struct Subject: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var colorHex: String
    var progress: Double // 0.0 to 1.0
    var targetScore: Int
    var currentScore: Int
    var icon: String
}
