//
//  FillerWordAnalyzer.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//


import Foundation
import SwiftUI
typealias SwiftUIColor = Color

// Result

struct FillerWordResult: Codable, Sendable {
    let counts: [String: Int]
    let total: Int
    let perMinute: Double
    let duration: TimeInterval

    var isEmpty: Bool { total == 0 }

    // Sorted highest count first
    var sorted: [(word: String, count: Int)] {
        counts
            .sorted { $0.value > $1.value }
            .map { (word: $0.key, count: $0.value) }
    }

    // How clean the speech is
    var rating: FillerRating {
        switch perMinute {
        case 0:         return .clean
        case 0..<2:     return .excellent
        case 2..<4:     return .good
        case 4..<6:     return .fair
        default:        return .heavy
        }
    }
}


enum FillerRating {
    case clean, excellent, good, fair, heavy

    var label: String {
        switch self {
        case .clean:     return "No Fillers"
        case .excellent: return "Excellent"
        case .good:      return "Good"
        case .fair:      return "Fair"
        case .heavy:     return "Heavy"
        }
    }

    var color: SwiftUIColor {
        switch self {
        case .clean, .excellent: return .green
        case .good:              return .cyan
        case .fair:              return .orange
        case .heavy:             return .red
        }
    }
}

// Need this so the enum can reference SwiftUI.Color without importing SwiftUI

struct FillerWordAnalyzer {

    // Filler Word Dictionary

    // Single words checked via exact match
    private static let singleFillers: Set<String> = [
        "um", "uh", "uhh", "umm", "erm",
        "like", "basically", "literally", "actually", "honestly",
        "right", "okay", "so", "well", "yeah",
        "anyway", "somehow", "whatever", "obviously"
    ]

    // Multi-word phrases checked via substring scan on full text.
    private static let multiWordFillers: [String] = [
        "you know",
        "i mean",
        "kind of",
        "sort of",
        "i guess",
        "or something",
        "and stuff",
        "or whatever",
        "i think",
        "at the end of the day"
    ]

    // skip if the word appears after a conjunction or preposition.
    private static let contextualFillers: Set<String> = [
        "so", "well", "right", "okay", "like"
    ]

    // Words that come before contextual fillers and make them not fillers
    private static let nonFillerPrecursors: Set<String> = [
        "is", "was", "are", "were", "not", "very", "would",
        "that", "if", "and", "but", "just", "look", "feel",
        "sounds", "seems", "it's", "that's"
    ]


    static func analyze(_ transcript: TranscriptResult) -> FillerWordResult {
        guard !transcript.isEmpty, transcript.duration > 0 else {
            return FillerWordResult(
                counts: [:],
                total: 0,
                perMinute: 0,
                duration: transcript.duration
            )
        }

        var counts: [String: Int] = [:]

        // Single-word fillers with context check
        let words = transcript.words
        for (index, word) in words.enumerated() {
            let lower = word.text.lowercased()
                .trimmingCharacters(in: .punctuationCharacters)

            guard singleFillers.contains(lower) else { continue }

            // Context check for ambiguous fillers
            if contextualFillers.contains(lower) {
                let previous = index > 0
                    ? words[index - 1].text.lowercased()
                        .trimmingCharacters(in: .punctuationCharacters)
                    : nil

                // Skip if preceded by a word that makes it not a filler
                if let prev = previous, nonFillerPrecursors.contains(prev) {
                    continue
                }
            }

            counts[lower, default: 0] += 1
        }

        // Multi-word fillers via full text scan
        let fullTextLower = transcript.fullText.lowercased()
        for phrase in multiWordFillers {
            let occurrences = countOccurrences(of: phrase, in: fullTextLower)
            if occurrences > 0 {
                counts[phrase, default: 0] += occurrences
            }
        }

        let total = counts.values.reduce(0, +)
        let minutes = transcript.duration / 60.0
        let perMinute = minutes > 0 ? Double(total) / minutes : 0

        return FillerWordResult(
            counts: counts,
            total: total,
            perMinute: perMinute,
            duration: transcript.duration
        )
    }

    // Helpers

    // Counts non-overlapping occurrences of a substring
    private static func countOccurrences(of target: String, in text: String) -> Int {
        var count = 0
        var searchRange = text.startIndex..<text.endIndex

        while let range = text.range(of: target, range: searchRange) {
            // Make sure it's a word boundary
            let before = range.lowerBound == text.startIndex
                || !text[text.index(before: range.lowerBound)].isLetter
            let after = range.upperBound == text.endIndex
                || !text[range.upperBound].isLetter

            if before && after {
                count += 1
            }

            searchRange = range.upperBound..<text.endIndex
        }

        return count
    }
}
