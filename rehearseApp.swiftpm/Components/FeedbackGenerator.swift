//
//  FeedbackGenerator.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//

import Foundation

// MARK: - FeedbackGenerator

struct FeedbackGenerator {

    // MARK: - Public API

    static func generate(from recording: Recording) -> PresentationFeedback {

        let duration = recording.duration
        let speakingRatio = recording.speakingRatio
        let avgPause = recording.averagePauseDuration
        let longPauseCount = recording.longPauseCount
        let volumeAnalysis = VolumeAnalysis.analyze(recording.volumeSamples ?? [])
        let hasVolumeData = volumeAnalysis.averageVolume != 0

        // Score Calculation

        let speakingScore = scoreSpeakingRatio(speakingRatio)
        let pauseScore = scorePauses(avgPause: avgPause, longPauses: longPauseCount)

        let overallScore: Int
        if hasVolumeData {
            overallScore = Int(
                speakingScore * 0.35 +
                pauseScore * 0.35 +
                volumeAnalysis.variationScore * 0.30
            )
        } else {
            overallScore = Int(
                speakingScore * 0.50 +
                pauseScore * 0.50
            )
        }

        let tone = determineTone(overallScore)

        return PresentationFeedback(
            overallScore: overallScore,
            tone: tone,
            summary: generateSummary(score: overallScore),
            durationText: formatDuration(duration),
            metrics: generateMetrics(
                speakingRatio: speakingRatio,
                longPauseCount: longPauseCount,
                volumeAnalysis: volumeAnalysis
            ),
            insights: generateInsights(
                speakingRatio: speakingRatio,
                avgPause: avgPause,
                longPauseCount: longPauseCount,
                duration: duration,
                volumeAnalysis: volumeAnalysis
            ),
            exercises: generateExercises(
                speakingRatio: speakingRatio,
                avgPause: avgPause,
                longPauseCount: longPauseCount,
                volumeAnalysis: volumeAnalysis
            )
        )
    }

    // MARK: - Score Calculations

    private static func scoreSpeakingRatio(_ ratio: Double) -> Double {
        switch ratio {
        case 0.65...0.80: return 100
        case 0.55..<0.65, 0.80..<0.90: return 80
        case 0.45..<0.55, 0.90..<0.95: return 60
        case 0.35..<0.45: return 40
        default: return 30
        }
    }

    private static func scorePauses(avgPause: Double, longPauses: Int) -> Double {
        var score = 100.0

        if avgPause > 2.0 {
            score -= 30
        } else if avgPause > 1.5 {
            score -= 15
        }

        if longPauses > 3 {
            score -= 25
        } else if longPauses > 1 {
            score -= 10
        }

        return max(30, score)
    }

    private static func determineTone(_ score: Int) -> FeedbackTone {
        switch score {
        case 80...100: return .excellent
        case 65..<80: return .good
        case 50..<65: return .developing
        default: return .needsWork
        }
    }

    // MARK: - Summary

    private static func generateSummary(score: Int) -> String {
        switch score {
        case 80...100:
            return "Excellent delivery! Your pacing was natural and your pauses were well-timed. Keep up the great work."
        case 65..<80:
            return "Good job! Your delivery was clear with a reasonable pace. A few small adjustments could make it even better."
        case 50..<65:
            return "Solid effort! Focus on smoothing out your pacing and being more intentional with pauses."
        default:
            return "Great that you're practicing! Focus on speaking more continuously and you'll see improvement quickly."
        }
    }

    // MARK: - Metrics (2 core + 1 optional)

    private static func generateMetrics(
        speakingRatio: Double,
        longPauseCount: Int,
        volumeAnalysis: VolumeAnalysis
    ) -> [DetailedMetric] {

        var metrics: [DetailedMetric] = []

        // Speaking Time

        let ratioRating: MetricRating = {
            switch speakingRatio {
            case 0.65...0.85: return .excellent
            case 0.50..<0.65, 0.85..<0.95: return .good
            case 0.40..<0.50: return .fair
            default: return .needsImprovement
            }
        }()

        metrics.append(DetailedMetric(
            name: "Speaking Time",
            value: "\(Int(speakingRatio * 100))%",
            rating: ratioRating,
            description: speakingRatio >= 0.65
                ? "Good balance of speaking and pausing"
                : "Try to fill more of your time with content",
            tip: speakingRatio < 0.5
                ? "Prepare key points beforehand to reduce hesitation"
                : nil,
            icon: "waveform"
        ))

        // Hesitations

        let hesitationRating: MetricRating = {
            switch longPauseCount {
            case 0: return .excellent
            case 1: return .good
            case 2...3: return .fair
            default: return .needsImprovement
            }
        }()

        metrics.append(DetailedMetric(
            name: "Hesitations",
            value: "\(longPauseCount)",
            rating: hesitationRating,
            description: longPauseCount == 0
                ? "No extended pauses detected"
                : "\(longPauseCount) pause\(longPauseCount == 1 ? "" : "s") over 2 seconds",
            tip: longPauseCount > 2
                ? "Practice transitions between your main points"
                : nil,
            icon: "exclamationmark.circle"
        ))

        // Vocal Energy (only if volume data exists)

        if volumeAnalysis.averageVolume != 0 {
            let energyRating: MetricRating = {
                if volumeAnalysis.isMonotone { return .needsImprovement }
                switch volumeAnalysis.variationScore {
                case 70...100: return .excellent
                case 50..<70: return .good
                case 30..<50: return .fair
                default: return .needsImprovement
                }
            }()

            metrics.append(DetailedMetric(
                name: "Vocal Energy",
                value: volumeAnalysis.isMonotone ? "Flat"
                    : volumeAnalysis.variationScore > 70 ? "Dynamic"
                    : "Moderate",
                rating: energyRating,
                description: volumeAnalysis.isMonotone
                    ? "Your volume stays very consistent"
                    : "Good variation in your delivery",
                tip: volumeAnalysis.isMonotone
                    ? "Try emphasizing key words by raising your volume"
                    : nil,
                icon: "speaker.wave.3"
            ))
        }

        return metrics
    }

    // MARK: - Insights (1 strength + 1 improvement + optional tip)

    private static func generateInsights(
        speakingRatio: Double,
        avgPause: Double,
        longPauseCount: Int,
        duration: Double,
        volumeAnalysis: VolumeAnalysis
    ) -> [FeedbackInsight] {

        var insights: [FeedbackInsight] = []

        insights.append(pickTopStrength(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            longPauseCount: longPauseCount,
            volumeAnalysis: volumeAnalysis
        ))

        if let improvement = pickTopImprovement(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            longPauseCount: longPauseCount,
            volumeAnalysis: volumeAnalysis
        ) {
            insights.append(improvement)
        }

        if let tip = pickTip(duration: duration) {
            insights.append(tip)
        }

        return insights
    }

    private static func pickTopStrength(
        speakingRatio: Double,
        avgPause: Double,
        longPauseCount: Int,
        volumeAnalysis: VolumeAnalysis
    ) -> FeedbackInsight {

        // Prioritized — return the first match

        if speakingRatio >= 0.65 && speakingRatio <= 0.85 {
            return FeedbackInsight(
                type: .strength,
                title: "Great Speaking Balance",
                description: "You maintained an ideal balance between speaking and pausing, which keeps audiences engaged."
            )
        }

        if longPauseCount == 0 {
            return FeedbackInsight(
                type: .strength,
                title: "Smooth Flow",
                description: "You avoided extended pauses, maintaining good momentum throughout."
            )
        }

        if avgPause >= 0.3 && avgPause <= 1.0 {
            return FeedbackInsight(
                type: .strength,
                title: "Confident Pausing",
                description: "Your pauses feel intentional rather than hesitant, projecting confidence."
            )
        }

        if volumeAnalysis.averageVolume != 0 && volumeAnalysis.variationScore > 70 {
            return FeedbackInsight(
                type: .strength,
                title: "Dynamic Delivery",
                description: "Great vocal variety! You naturally vary your volume, which keeps listeners engaged."
            )
        }

        return FeedbackInsight(
            type: .strength,
            title: "You're Practicing!",
            description: "Showing up to practice is the most important step. Consistent practice leads to improvement."
        )
    }

    private static func pickTopImprovement(
        speakingRatio: Double,
        avgPause: Double,
        longPauseCount: Int,
        volumeAnalysis: VolumeAnalysis
    ) -> FeedbackInsight? {

        // Prioritized by severity — return the worst issue

        if speakingRatio < 0.45 {
            return FeedbackInsight(
                type: .improvement,
                title: "Increase Speaking Time",
                description: "You spent less than half your time speaking. Preparing key points beforehand can help reduce hesitation."
            )
        }

        if longPauseCount > 2 {
            return FeedbackInsight(
                type: .improvement,
                title: "Reduce Hesitation Pauses",
                description: "You had \(longPauseCount) pauses over 2 seconds. Practice your transitions to keep momentum."
            )
        }

        if avgPause > 1.5 {
            return FeedbackInsight(
                type: .improvement,
                title: "Shorten Your Pauses",
                description: "Your average pause is quite long. Try bridge phrases like 'Building on that...' to stay in flow."
            )
        }

        if volumeAnalysis.averageVolume != 0 && volumeAnalysis.isMonotone {
            return FeedbackInsight(
                type: .improvement,
                title: "Add Vocal Variety",
                description: "Your volume stays flat. Try raising your voice for key points and lowering it for emphasis."
            )
        }

        if speakingRatio > 0.92 {
            return FeedbackInsight(
                type: .improvement,
                title: "Add Strategic Pauses",
                description: "Intentional pauses emphasize key points and give your audience time to absorb information."
            )
        }

        return nil
    }

    private static func pickTip(duration: Double) -> FeedbackInsight? {
        if duration < 60 {
            return FeedbackInsight(
                type: .tip,
                title: "Try Longer Sessions",
                description: "Longer practice sessions (2-5 minutes) give more reliable feedback on your natural speaking patterns."
            )
        }

        return nil
    }

    // MARK: - Exercises (1 targeted + 1 closing)

    private static func generateExercises(
        speakingRatio: Double,
        avgPause: Double,
        longPauseCount: Int,
        volumeAnalysis: VolumeAnalysis
    ) -> [PracticeExercise] {

        var exercises: [PracticeExercise] = []

        exercises.append(pickTargetedExercise(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            longPauseCount: longPauseCount,
            volumeAnalysis: volumeAnalysis
        ))

        exercises.append(PracticeExercise(
            title: "Record & Compare",
            description: "Do another recording and compare your metrics. Small improvements add up over time!",
            duration: "2 min",
            icon: "arrow.triangle.2.circlepath"
        ))

        return exercises
    }

    private static func pickTargetedExercise(
        speakingRatio: Double,
        avgPause: Double,
        longPauseCount: Int,
        volumeAnalysis: VolumeAnalysis
    ) -> PracticeExercise {

        // Prioritized by severity

        if speakingRatio < 0.5 {
            return PracticeExercise(
                title: "Preparation Practice",
                description: "Write down 3 bullet points, then speak about each for 30 seconds. Structure reduces hesitation.",
                duration: "3 min",
                icon: "list.bullet"
            )
        }

        if avgPause > 1.5 || longPauseCount > 2 {
            return PracticeExercise(
                title: "Bridge Phrases",
                description: "Practice using transitions like 'Building on that...', 'This connects to...' to fill pauses naturally.",
                duration: "3 min",
                icon: "link"
            )
        }

        if volumeAnalysis.averageVolume != 0 && volumeAnalysis.isMonotone {
            return PracticeExercise(
                title: "Emphasis Practice",
                description: "Pick a sentence and say it 3 ways: emphasize the first word, the middle, then the last.",
                duration: "3 min",
                icon: "waveform.path.ecg"
            )
        }

        if speakingRatio > 0.90 {
            return PracticeExercise(
                title: "Intentional Pauses",
                description: "Practice pausing for 1-2 seconds after each main point. Pauses add emphasis and let ideas sink in.",
                duration: "3 min",
                icon: "pause.fill"
            )
        }

        return PracticeExercise(
            title: "1-Minute Free Flow",
            description: "Speak about any topic for 60 seconds without stopping. Focus on continuous flow, not perfection.",
            duration: "1 min",
            icon: "flame.fill"
        )
    }

    // MARK: - Helpers

    private static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds) seconds"
        }
    }
}
