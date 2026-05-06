//
//  NoteTests.swift
//  LearnTrackTests
//
//  Created by COBSCCOMP242P-028 on 2026-05-06.
//

import XCTest
@testable import LearnTrack

class NoteTests: XCTestCase {

    func testNoteInitialization() {
        let date = Date()
        let note = Note(title: "Test Note", content: "This is a test note", colorHex: "#FF0000", category: "Study", dateCreated: date, attachedFileNames: ["file1.pdf", "file2.jpg"])
        
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "This is a test note")
        XCTAssertEqual(note.colorHex, "#FF0000")
        XCTAssertEqual(note.category, "Study")
        XCTAssertEqual(note.dateCreated, date)
        XCTAssertEqual(note.attachedFileNames, ["file1.pdf", "file2.jpg"])
        XCTAssertNotNil(note.id)
    }

    func testNoteColor() {
        let note = Note(title: "Test", content: "Content", colorHex: "#FF0000", category: "Test", dateCreated: Date(), attachedFileNames: [])
        XCTAssertEqual(note.color, Color(hex: "#FF0000"))
    }

    func testNoteDateString() {
        let date = Date()
        let note = Note(title: "Test", content: "Content", colorHex: "#000000", category: "Test", dateCreated: date, attachedFileNames: [])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let expectedDateString = formatter.string(from: date)
        
        XCTAssertEqual(note.dateString, expectedDateString)
    }

    func testNoteHashable() {
        let id = UUID()
        let date = Date()
        let note1 = Note(id: id, title: "Note 1", content: "Content 1", colorHex: "#FF0000", category: "Study", dateCreated: date, attachedFileNames: [])
        let note2 = Note(id: id, title: "Note 1", content: "Content 1", colorHex: "#FF0000", category: "Study", dateCreated: date, attachedFileNames: [])
        
        XCTAssertEqual(note1, note2)
        XCTAssertEqual(note1.hashValue, note2.hashValue)
    }

    func testNoteWithEmptyAttachments() {
        let note = Note(title: "Test", content: "Content", colorHex: "#000000", category: "Test", dateCreated: Date(), attachedFileNames: [])
        XCTAssertTrue(note.attachedFileNames.isEmpty)
    }

    func testNoteWithMultipleAttachments() {
        let attachments = ["doc1.pdf", "image1.jpg", "audio1.mp3", "video1.mp4"]
        let note = Note(title: "Test", content: "Content", colorHex: "#000000", category: "Test", dateCreated: Date(), attachedFileNames: attachments)
        XCTAssertEqual(note.attachedFileNames.count, 4)
        XCTAssertEqual(note.attachedFileNames, attachments)
    }
}