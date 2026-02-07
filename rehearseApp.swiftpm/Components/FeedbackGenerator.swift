//
//  FeedbackGenerator.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//

import Foundation

struct FeedbackGenerator {

    static func generate(from recording: Recording) -> PresentationFeedback {
        
        // MARK: - Basic Metrics
        
        let duration = recording.duration
        let speakingTime = recording.speakingTime
        let speakingRatio = recording.speakingRatio
        let avgPause = recording.averagePauseDuration
        let avgSegment = recording.averageSpeakingSegmentLength
        let longPauseCount = recording.longPauseCount
        let pauseCount = recording.pauses.count
        
        // MARK: - Pause Distribution Analysis
        
        let pauseDistribution = analyzePauseDistribution(recording.pauses)
        
        // MARK: - Calculate Scores
        
        let speakingRatioScore = calculateSpeakingRatioScore(speakingRatio)
        let pauseScore = calculatePauseScore(avgPause: avgPause, longPauses: longPauseCount, totalPauses: pauseCount)
        let segmentScore = calculateSegmentScore(avgSegment)
        let consistencyScore = calculateConsistencyScore(pauses: recording.pauses)
        
        // Overall weighted score
        let overallScore = Int(
            speakingRatioScore * 0.3 +
            pauseScore * 0.3 +
            segmentScore * 0.25 +
            consistencyScore * 0.15
        )
        
        // MARK: - Determine Tone
        
        let tone: FeedbackTone = {
            switch overallScore {
            case 80...100: return .excellent
            case 65..<80: return .good
            case 50..<65: return .developing
            default: return .needsWork
            }
        }()
        
        // MARK: - Summary
        
        let summary = generateSummary(
            score: overallScore,
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            avgSegment: avgSegment
        )
        
        // MARK: - Detailed Metrics
        
        let metrics = generateDetailedMetrics(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            avgSegment: avgSegment,
            longPauseCount: longPauseCount,
            duration: duration,
            speakingTime: speakingTime,
            pauseCount: pauseCount
        )
        
        // MARK: - Insights
        
        let insights = generateInsights(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            avgSegment: avgSegment,
            longPauseCount: longPauseCount,
            pauseDistribution: pauseDistribution,
            duration: duration
        )
        
        // MARK: - Pace Category
        
        let (paceCategory, paceDescription) = analyzePace(
            speakingRatio: speakingRatio,
            avgSegment: avgSegment,
            avgPause: avgPause
        )
        
        // MARK: - Practice Exercises
        
        let exercises = generateExercises(
            speakingRatio: speakingRatio,
            avgPause: avgPause,
            avgSegment: avgSegment,
            longPauseCount: longPauseCount
        )
        
        return PresentationFeedback(
            overallScore: overallScore,
            tone: tone,
            summary: summary,
            durationText: formatDuration(duration),
            metrics: metrics,
            insights: insights,
            paceCategory: paceCategory,
            paceDescription: paceDescription,
            pauseDistribution: pauseDistribution,
            practiceExercises: exercises
        )
    }
    
    // MARK: - Pause Distribution Analysis
    
    private static func analyzePauseDistribution(_ pauses: [TimeInterval]) -> PauseDistribution {
        var short = 0
        var medium = 0
        var long = 0
        var veryLong = 0
        
        for pause in pauses {
            switch pause {
            case ..<0.5:
                short += 1
            case 0.5..<1.5:
                medium += 1
            case 1.5..<3.0:
                long += 1
            default:
                veryLong += 1
            }
        }
        
        return PauseDistribution(
            shortPauses: short,
            mediumPauses: medium,
            longPauses: long,
            veryLongPauses: veryLong
        )
    }
    
    // MARK: - Score Calculations
    
    private static func calculateSpeakingRatioScore(_ ratio: Double) -> Double {
        // Ideal range: 0.6 - 0.8
        switch ratio {
        case 0.65...0.80:
            return 100
        case 0.55..<0.65, 0.80..<0.90:
            return 80
        case 0.45..<0.55, 0.90..<0.95:
            return 60
        case 0.35..<0.45:
            return 40
        default:
            return 30
        }
    }
    
    private static func calculatePauseScore(avgPause: Double, longPauses: Int, totalPauses: Int) -> Double {
        var score = 100.0
        
        // Penalize for average pause length
        if avgPause > 2.0 {
            score -= 30
        } else if avgPause > 1.5 {
            score -= 15
        } else if avgPause < 0.3 && totalPauses > 5 {
            score -= 10 // Too many micro-pauses
        }
        
        // Penalize for too many long pauses
        if longPauses > 3 {
            score -= 25
        } else if longPauses > 1 {
            score -= 10
        }
        
        return max(30, score)
    }
    
    private static func calculateSegmentScore(_ avgSegment: Double) -> Double {
        // Ideal range: 5-15 seconds per segment
        switch avgSegment {
        case 5...15:
            return 100
        case 3..<5, 15..<20:
            return 75
        case 2..<3, 20..<30:
            return 50
        default:
            return 35
        }
    }
    
    private static func calculateConsistencyScore(pauses: [TimeInterval]) -> Double {
        guard pauses.count > 1 else { return 70 }
        
        let mean = pauses.reduce(0, +) / Double(pauses.count)
        let variance = pauses.reduce(0) { $0 + pow($1 - mean, 2) } / Double(pauses.count)
        let stdDev = sqrt(variance)
        
        // Lower standard deviation = more consistent
        let coefficientOfVariation = stdDev / mean
        
        if coefficientOfVariation < 0.3 {
            return 100
        } else if coefficientOfVariation < 0.5 {
            return 80
        } else if coefficientOfVariation < 0.8 {
            return 60
        } else {
            return 40
        }
    }
    
    // MARK: - Summary Generation
    
    private static func generateSummary(
        score: Int,
        speakingRatio: Double,
        avgPause: Double,
        avgSegment: Double
    ) -> String {
        switch score {
        case 80...100:
            return "Excellent delivery! Your pacing was natural and your pauses were well-timed. Keep up the great work."
        case 65..<80:
            return "Good job! Your delivery was clear and you maintained a reasonable pace. A few small adjustments could make it even better."
        case 50..<65:
            return "Solid effort! You're developing good habits. Focus on smoothing out your pacing and being more intentional with pauses."
        default:
            return "Great that you're practicing! Everyone starts somewhere. Focus on speaking more continuously and you'll see improvement quickly."
        }
    }
    
    // MARK: - Detailed Metrics Generation
    
    private static func generateDetailedMetrics(
        speakingRatio: Double,
        avgPause: Double,
        avgSegment: Double,
        longPauseCount: Int,
        duration: Double,
        speakingTime: Double,
        pauseCount: Int
    ) -> [DetailedMetric] {
        
        var metrics: [DetailedMetric] = []
        
        // Speaking Ratio
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
            description: "You spoke for \(Int(speakingRatio * 100))% of your recording",
            tip: speakingRatio < 0.5 ? "Try to fill more of your time with content" : nil,
            icon: "waveform"
        ))
        
        // Average Pause
        let pauseRating: MetricRating = {
            switch avgPause {
            case 0.3..<1.0: return .excellent
            case 1.0..<1.5: return .good
            case 1.5..<2.5: return .fair
            default: return .needsImprovement
            }
        }()
        
        metrics.append(DetailedMetric(
            name: "Avg Pause",
            value: String(format: "%.1fs", avgPause),
            rating: pauseRating,
            description: avgPause < 1.0 ? "Quick, confident pauses" : avgPause < 2.0 ? "Moderate pause length" : "Extended pauses",
            tip: avgPause > 1.5 ? "Practice bridging your thoughts more smoothly" : nil,
            icon: "pause.circle"
        ))
        
        // Segment Length
        let segmentRating: MetricRating = {
            switch avgSegment {
            case 5...15: return .excellent
            case 3..<5, 15..<25: return .good
            case 2..<3, 25..<35: return .fair
            default: return .needsImprovement
            }
        }()
        
        metrics.append(DetailedMetric(
            name: "Avg Segment",
            value: String(format: "%.1fs", avgSegment),
            rating: segmentRating,
            description: avgSegment < 5 ? "Short, choppy segments" : avgSegment < 15 ? "Well-paced segments" : "Long segments",
            tip: avgSegment < 5 ? "Try grouping related thoughts together" : nil,
            icon: "text.alignleft"
        ))
        
        // Long Pauses
        let longPauseRating: MetricRating = {
            switch longPauseCount {
            case 0: return .excellent
            case 1: return .good
            case 2...3: return .fair
            default: return .needsImprovement
            }
        }()
        
        metrics.append(DetailedMetric(
            name: "Long Pauses",
            value: "\(longPauseCount)",
            rating: longPauseRating,
            description: longPauseCount == 0 ? "No hesitation pauses detected" : "\(longPauseCount) pause\(longPauseCount == 1 ? "" : "s") over 2 seconds",
            tip: longPauseCount > 2 ? "Practice transitions between your main points" : nil,
            icon: "exclamationmark.circle"
        ))
        
        // Fluency (pauses per minute)
        let pausesPerMinute = duration > 0 ? Double(pauseCount) / (duration / 60) : 0
        let fluencyRating: MetricRating = {
            switch pausesPerMinute {
            case ..<8: return .excellent
            case 8..<12: return .good
            case 12..<16: return .fair
            default: return .needsImprovement
            }
        }()
        
        metrics.append(DetailedMetric(
            name: "Fluency",
            value: String(format: "%.0f/min", pausesPerMinute),
            rating: fluencyRating,
            description: "\(Int(pausesPerMinute)) pauses per minute",
            tip: pausesPerMinute > 15 ? "Work on speaking in longer phrases" : nil,
            icon: "water.waves"
        ))
        
        return metrics
    }
    
    // MARK: - Insights Generation
    
    private static func generateInsights(
        speakingRatio: Double,
        avgPause: Double,
        avgSegment: Double,
        longPauseCount: Int,
        pauseDistribution: PauseDistribution,
        duration: Double
    ) -> [FeedbackInsight] {
        
        var insights: [FeedbackInsight] = []
        
        // STRENGTHS
        if speakingRatio >= 0.65 && speakingRatio <= 0.85 {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "Great Speaking Balance",
                description: "You maintained an ideal balance between speaking and pausing, which keeps audiences engaged."
            ))
        }
        
        if avgSegment >= 5 && avgSegment <= 15 {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "Well-Paced Segments",
                description: "Your speaking segments are a comfortable length—easy to follow without feeling rushed or slow."
            ))
        }
        
        if avgPause < 1.0 && avgPause > 0.3 {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "Confident Pausing",
                description: "Your pauses feel intentional rather than hesitant, projecting confidence."
            ))
        }
        
        if longPauseCount == 0 {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "Smooth Flow",
                description: "You avoided extended pauses, maintaining good momentum throughout."
            ))
        }
        
        if pauseDistribution.mediumPauses > pauseDistribution.total / 2 {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "Natural Rhythm",
                description: "Most of your pauses fall in the natural 0.5-1.5 second range, creating a comfortable listening experience."
            ))
        }
        
        // IMPROVEMENTS
        if speakingRatio < 0.5 {
            insights.append(FeedbackInsight(
                type: .improvement,
                title: "Increase Speaking Time",
                description: "You spent less than half your time speaking. Try to reduce hesitation by preparing your key points beforehand."
            ))
        }
        
        if avgPause > 1.5 {
            insights.append(FeedbackInsight(
                type: .improvement,
                title: "Shorten Your Pauses",
                description: "Your average pause is quite long. Practice transitioning between ideas more smoothly."
            ))
        }
        
        if avgSegment < 4 {
            insights.append(FeedbackInsight(
                type: .improvement,
                title: "Speak in Longer Phrases",
                description: "Your segments are short, which can feel choppy. Try grouping 2-3 related thoughts before pausing."
            ))
        }
        
        if longPauseCount > 2 {
            insights.append(FeedbackInsight(
                type: .improvement,
                title: "Reduce Hesitation Pauses",
                description: "You had \(longPauseCount) pauses over 2 seconds. These might indicate uncertainty—practice your transitions."
            ))
        }
        
        if pauseDistribution.veryLongPauses > 1 {
            insights.append(FeedbackInsight(
                type: .improvement,
                title: "Mind the Long Gaps",
                description: "Extended pauses (3+ seconds) can lose your audience. If you need to think, use a bridge phrase like 'Let me explain...'"
            ))
        }
        
        // TIPS
        if duration < 60 {
            insights.append(FeedbackInsight(
                type: .tip,
                title: "Try Longer Sessions",
                description: "Longer practice sessions (2-5 minutes) give more reliable feedback on your natural speaking patterns."
            ))
        }
        
        if speakingRatio > 0.9 {
            insights.append(FeedbackInsight(
                type: .tip,
                title: "Add Strategic Pauses",
                description: "Intentional pauses can emphasize key points and give your audience time to absorb information."
            ))
        }
        
        // Ensure we have at least one of each type if possible
        let hasStrength = insights.contains { $0.type == .strength }
        let hasImprovement = insights.contains { $0.type == .improvement }
        
        if !hasStrength {
            insights.append(FeedbackInsight(
                type: .strength,
                title: "You're Practicing!",
                description: "Showing up to practice is the most important step. Consistent practice leads to improvement."
            ))
        }
        
        if !hasImprovement && duration >= 30 {
            insights.append(FeedbackInsight(
                type: .tip,
                title: "Challenge Yourself",
                description: "Try practicing with more complex material or adding time pressure to continue improving."
            ))
        }
        
        return insights
    }
    
    // MARK: - Pace Analysis
    
    private static func analyzePace(
        speakingRatio: Double,
        avgSegment: Double,
        avgPause: Double
    ) -> (PaceCategory, String) {
        
        // Calculate effective pace score
        let paceScore = (speakingRatio * 0.4) + (min(avgSegment, 20) / 20 * 0.3) + ((2 - min(avgPause, 2)) / 2 * 0.3)
        
        let category: PaceCategory
        let description: String
        
        if paceScore > 0.75 {
            category = .fast
            description = "You're speaking at a brisk pace. This can convey energy and confidence, but make sure key points land."
        } else if paceScore > 0.6 {
            category = .ideal
            description = "Your pace is well-balanced—fast enough to maintain interest, slow enough for clarity."
        } else if paceScore > 0.45 {
            category = .slow
            description = "You're speaking at a measured pace. This works for complex topics but could feel slow for simpler content."
        } else {
            category = .tooSlow
            description = "Your pace is quite slow, which may cause attention to drift. Try building more momentum."
        }
        
        return (category, description)
    }
    
    // MARK: - Practice Exercises
    
    private static func generateExercises(
        speakingRatio: Double,
        avgPause: Double,
        avgSegment: Double,
        longPauseCount: Int
    ) -> [PracticeExercise] {
        
        var exercises: [PracticeExercise] = []
        
        // Always include a general warm-up
        exercises.append(PracticeExercise(
            title: "1-Minute Warm-Up",
            description: "Speak about your day for 60 seconds without stopping. Focus on continuous flow, not perfection.",
            duration: "1 min",
            icon: "flame.fill"
        ))
        
        // Targeted exercises based on weaknesses
        if avgPause > 1.5 || longPauseCount > 2 {
            exercises.append(PracticeExercise(
                title: "Bridge Phrases",
                description: "Practice using transition phrases like 'Building on that...', 'This connects to...', 'Let me explain...' to fill pauses.",
                duration: "3 min",
                icon: "link"
            ))
        }
        
        if avgSegment < 5 {
            exercises.append(PracticeExercise(
                title: "Thought Grouping",
                description: "Take a topic and practice explaining it in 3-4 complete sentences before pausing. Aim for 10-15 second segments.",
                duration: "5 min",
                icon: "square.stack.3d.up"
            ))
        }
        
        if speakingRatio < 0.5 {
            exercises.append(PracticeExercise(
                title: "Preparation Practice",
                description: "Write down 3 bullet points, then speak about each for 30 seconds. Having structure reduces hesitation.",
                duration: "3 min",
                icon: "list.bullet"
            ))
        }
        
        if avgPause < 0.5 && speakingRatio > 0.85 {
            exercises.append(PracticeExercise(
                title: "Intentional Pauses",
                description: "Practice pausing for 1-2 seconds after each main point. Pauses add emphasis and let ideas sink in.",
                duration: "3 min",
                icon: "pause.fill"
            ))
        }
        
        // Add a closing exercise
        exercises.append(PracticeExercise(
            title: "Record & Compare",
            description: "Do another recording and compare your metrics. Small improvements add up over time!",
            duration: "2 min",
            icon: "arrow.triangle.2.circlepath"
        ))
        
        return exercises
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
