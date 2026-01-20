//
//  FeedbackGenerator.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//

import Foundation

struct FeedbackGenerator {

    static func generate(from recording: Recording) -> PresentationFeedback {

        let durationText = formatDuration(recording.duration)

        let speakingRatio = recording.speakingRatio
        let avgPause = recording.averagePauseDuration
        let avgSegment = recording.averageSpeakingSegmentLength
        let longPauses = recording.longPauseCount

        // MARK: - Determine Focus Areas

        enum Focus {
            case speakingRatio
            case pauses
            case segmentLength
        }

        // Strength detection
        let strength: Focus =
            (avgSegment >= 5 && avgSegment <= 12) ? .segmentLength :
            (speakingRatio >= 0.6 && speakingRatio <= 0.8) ? .speakingRatio :
            .segmentLength

        // Weakness detection
        let improvement: Focus =
            (avgPause > 1.5 || longPauses >= 2) ? .pauses :
            (speakingRatio < 0.5) ? .speakingRatio :
            .segmentLength

        // MARK: - Tone

        let tone: FeedbackTone
        let summary: String

        if speakingRatio >= 0.6 && avgPause <= 1.5 && avgSegment >= 5 {
            tone = .positive
            summary = "Confident delivery with clear pacing."
        } else if speakingRatio >= 0.45 {
            tone = .neutral
            summary = "Steady delivery with room to refine pacing."
        } else {
            tone = .needsWork
            summary = "Your delivery showed effort, but pacing needs refinement."
        }

        // MARK: - What Went Well (ALWAYS SPECIFIC)

        let whatWentWell: String
        switch strength {
        case .segmentLength:
            whatWentWell =
                "You spoke in well‑paced segments, which made your ideas easy to follow."
        case .speakingRatio:
            whatWentWell =
                "You maintained strong momentum and avoided over‑pausing."
        case .pauses:
            whatWentWell =
                "Your pauses were generally controlled and didn’t interrupt your flow."
        }

        // MARK: - For Next Time (ALWAYS ACTIONABLE)

        let improvementSuggestion: String
        switch improvement {
        case .pauses:
            improvementSuggestion =
                "Try shortening longer pauses to keep your audience engaged."
        case .speakingRatio:
            improvementSuggestion =
                "Aim to speak a bit more continuously to build confidence and flow."
        case .segmentLength:
            improvementSuggestion =
                "Try grouping your thoughts into slightly longer phrases before pausing."
        }

        return PresentationFeedback(
            summary: summary,
            tone: tone,
            whatWentWell: whatWentWell,
            improvementSuggestion: improvementSuggestion,
            durationText: "You spoke for \(durationText)"
        )
    }

    private static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes) minute\(minutes == 1 ? "" : "s") and \(seconds) second\(seconds == 1 ? "" : "s")"
    }
}
