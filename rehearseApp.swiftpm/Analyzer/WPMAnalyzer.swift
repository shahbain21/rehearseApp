//
//  WPMAnalyzer.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/24/26.
//

import Foundation
import SwiftUI

// Struct assigning values to wpm
struct WPMResult: Codable, Sendable {
    let wpm: Double
    let wordCount: Int
    let duration: TimeInterval

    var rating: WPMRating {
        switch wpm {
        case 0..<100:     return .tooSlow
        case 100..<130:   return .slow
        case 130..<170:   return .ideal
        case 170..<200:   return .fast
        default:          return .tooFast
        }
    }
}


enum WPMRating {
    case tooSlow, slow, ideal, fast, tooFast

    var label: String {
        switch self {
        case .tooSlow: return "Too Slow"
        case .slow:    return "Slow"
        case .ideal:   return "Ideal"
        case .fast:    return "Fast"
        case .tooFast: return "Too Fast"
        }
    }

    var color: Color {
        switch self {
        case .tooSlow:  return .orange
        case .slow:     return .cyan
        case .ideal:    return .green
        case .fast:     return .yellow
        case .tooFast:  return .red
        }
    }

    var description: String {
        switch self {
        case .tooSlow:
            return "You're speaking quite slowly. Try to maintain a more natural conversational pace."
        case .slow:
            return "Slightly below average pace. This works for emphasis, but try picking it up during regular flow."
        case .ideal:
            return "Perfect pace! Clear and easy to follow — great for any speaking situation."
        case .fast:
            return "You're speaking a bit fast. Try slowing down at key moments to let your words land."
        case .tooFast:
            return "Too fast for most listeners to follow comfortably. Practice pausing between ideas."
        }
    }

    var icon: String {
        switch self {
        case .tooSlow:  return "tortoise"
        case .slow:     return "figure.walk"
        case .ideal:    return "checkmark.circle"
        case .fast:     return "hare"
        case .tooFast:  return "exclamationmark.triangle"
        }
    }
}

// Finding wpm by dividing words in transcript by time
struct WPMAnalyzer {

    static func analyze(_ transcript: TranscriptResult) -> WPMResult {
        guard !transcript.isEmpty, transcript.duration > 0 else {
            return WPMResult(wpm: 0, wordCount: 0, duration: 0)
        }

        let minutes = transcript.duration / 60.0
        let wpm = Double(transcript.wordCount) / minutes

        return WPMResult(
            wpm: wpm,
            wordCount: transcript.wordCount,
            duration: transcript.duration
        )
    }
}
