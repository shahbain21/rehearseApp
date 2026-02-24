//
//  TranscriptModel.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import Foundation

struct TranscriptResult: Codable, Sendable {
    let fullText: String
    let words: [TranscriptWord]
    let duration: TimeInterval

    var wordCount: Int { words.count }
    var isEmpty: Bool { words.isEmpty }
}


struct TranscriptWord: Codable {
    let text: String
    let timestamp: TimeInterval
    let duration: TimeInterval
    let confidence: Float
}
