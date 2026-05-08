//
//  Note.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import Foundation
import SwiftUI

struct NoteAttachment: Identifiable, Hashable, Codable {
    enum AttachmentType: String, Codable, Hashable {
        case image
        case document
    }
    
    let id: UUID
    let name: String
    let path: String
    let type: AttachmentType
    
    var url: URL {
        URL(fileURLWithPath: path)
    }
    
    var isImage: Bool {
        type == .image
    }
}

struct Note: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var colorHex: String
    var category: String
    var dateCreated: Date
    var attachments: [NoteAttachment]
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        colorHex: String,
        category: String,
        dateCreated: Date,
        attachments: [NoteAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.colorHex = colorHex
        self.category = category
        self.dateCreated = dateCreated
        self.attachments = attachments
    }
    
    var attachmentNames: [String] {
        attachments.map { $0.name }
    }
    
    var color: Color {
        Color(UIColor(hex: colorHex))
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: dateCreated)
    }
}
