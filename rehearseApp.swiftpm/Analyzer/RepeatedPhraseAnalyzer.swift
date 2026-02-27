//
//  RepeatedPhraseAnalyzer.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/24/26.
//

import Foundation
import SwiftUI


struct RepeatedPhraseResult: Codable, Sendable {
    let phrases: [RepeatedPhrase]
    let totalRepeats: Int
    let duration: TimeInterval

    var isEmpty: Bool { phrases.isEmpty }

    var rating: RepetitionRating {
        let perMinute = duration > 0
            ? Double(totalRepeats) / (duration / 60.0)
            : 0

        switch perMinute {
        case 0:       return .clean
        case 0..<1:   return .minimal
        case 1..<3:   return .moderate
        default:      return .heavy
        }
    }
}

// Phrase structure
struct RepeatedPhrase: Codable, Sendable, Identifiable {
    var id: String { phrase }
    let phrase: String
    let count: Int
    let wordCount: Int
}


enum RepetitionRating {
    case clean, minimal, moderate, heavy

    var label: String {
        switch self {
        case .clean:    return "No Repeats"
        case .minimal:  return "Minimal"
        case .moderate: return "Moderate"
        case .heavy:    return "Heavy"
        }
    }

    var color: Color {
        switch self {
        case .clean, .minimal: return .green
        case .moderate:        return .orange
        case .heavy:           return .red
        }
    }

    var description: String {
        switch self {
        case .clean:
            return "No repeated phrases detected. Great variety in your word choices!"
        case .minimal:
            return "Very few repeated phrases. Your speech sounds natural and varied."
        case .moderate:
            return "Some phrases are coming up often. Try varying your word choices to keep listeners engaged."
        case .heavy:
            return "You're relying on the same phrases frequently. Practice using different ways to express the same ideas."
        }
    }
}


struct RepeatedPhraseAnalyzer {

    // Common phrases that are expected and not worth flagging
    private static let ignoredPhrases: Set<String> = [
        "in the", "on the", "at the", "to the", "of the",
        "for the", "and the", "with the", "from the",
        "it is", "it was", "it's a", "that is", "that was",
        "this is", "this was", "there is", "there was",
        "and i", "and then", "but i", "so i", "and it",
        "i was", "i am", "i had", "i have", "i think",
        "going to", "want to", "have to", "need to",
        "able to", "got to", "used to",
        "a lot of", "one of the", "some of the",
        "i want to", "i need to", "i have to",
        "i was going", "i think that", "i think it",
        "going to be", "it was a", "there was a",
        "i don't know", "i don't think"
    ]

    // Minimum times a phrase must appear to count as repeated
    private static let minCount = 3

    static func analyze(_ transcript: TranscriptResult) -> RepeatedPhraseResult {
        guard !transcript.isEmpty, transcript.duration > 0 else {
            return RepeatedPhraseResult(
                phrases: [],
                totalRepeats: 0,
                duration: transcript.duration
            )
        }

        // Clean words — lowercase, remove punctuation
        let words = transcript.words.map { word in
            word.text.lowercased()
                .trimmingCharacters(in: .punctuationCharacters)
        }
        .filter { !$0.isEmpty }

        guard words.count >= 2 else {
            return RepeatedPhraseResult(
                phrases: [],
                totalRepeats: 0,
                duration: transcript.duration
            )
        }

        // Find n-grams of size 2, 3, and 4
        var allPhrases: [RepeatedPhrase] = []

        for n in 2...4 {
            let found = findRepeatedNGrams(words: words, n: n)
            allPhrases.append(contentsOf: found)
        }

        // Remove phrases that are subsets of longer repeated phrases
        allPhrases = removeSubPhrases(allPhrases)

        // Sort by count (most repeated first), then by word count (longer first)
        allPhrases.sort { a, b in
            if a.count != b.count { return a.count > b.count }
            return a.wordCount > b.wordCount
        }

        // Cap at 8 most significant
        let capped = Array(allPhrases.prefix(8))

        let totalRepeats = capped.reduce(0) { $0 + ($1.count - 1) }

        return RepeatedPhraseResult(
            phrases: capped,
            totalRepeats: totalRepeats,
            duration: transcript.duration
        )
    }

    // N-Gram Extraction

    private static func findRepeatedNGrams(words: [String], n: Int) -> [RepeatedPhrase] {
        guard words.count >= n else { return [] }

        var counts: [String: Int] = [:]

        for i in 0...(words.count - n) {
            let phrase = words[i..<(i + n)].joined(separator: " ")
            counts[phrase, default: 0] += 1
        }

        return counts.compactMap { phrase, count in
            guard count >= minCount else { return nil }
            guard !ignoredPhrases.contains(phrase) else { return nil }

            // Skip phrases that are all the same word ("the the the")
            let uniqueWords = Set(phrase.split(separator: " "))
            guard uniqueWords.count > 1 else { return nil }

            return RepeatedPhrase(
                phrase: phrase,
                count: count,
                wordCount: n
            )
        }
    }

    // Remove Sub-Phrases

    private static func removeSubPhrases(_ phrases: [RepeatedPhrase]) -> [RepeatedPhrase] {
        var result: [RepeatedPhrase] = []

        let sorted = phrases.sorted { $0.wordCount > $1.wordCount }

        for phrase in sorted {
            let isSubPhrase = result.contains { longer in
                longer.wordCount > phrase.wordCount
                && longer.phrase.contains(phrase.phrase)
                && longer.count >= phrase.count
            }

            if !isSubPhrase {
                result.append(phrase)
            }
        }

        return result
    }
}
