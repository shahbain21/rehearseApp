//
//  PresentationFeedback.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//
import SwiftUI

// MARK: - Feedback Tone

enum FeedbackTone {
    case excellent
    case good
    case developing
    case needsWork

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .cyan
        case .developing: return .yellow
        case .needsWork: return .orange
        }
    }

    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .developing: return "Developing"
        case .needsWork: return "Needs Work"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .developing: return "arrow.up.circle.fill"
        case .needsWork: return "target"
        }
    }
}

// MARK: - Metric Rating

enum MetricRating {
    case excellent
    case good
    case fair
    case needsImprovement
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .cyan
        case .fair: return .yellow
        case .needsImprovement: return .orange
        }
    }
    
    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .needsImprovement: return "Needs Improvement"
        }
    }
}

// MARK: - Detailed Metric

struct DetailedMetric {
    let name: String
    let value: String
    let rating: MetricRating
    let description: String
    let tip: String?
    let icon: String
}

// MARK: - Insight

struct FeedbackInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    
    enum InsightType {
        case strength
        case improvement
        case tip
        
        var icon: String {
            switch self {
            case .strength: return "checkmark.circle.fill"
            case .improvement: return "arrow.up.circle.fill"
            case .tip: return "lightbulb.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .strength: return .green
            case .improvement: return .orange
            case .tip: return .cyan
            }
        }
    }
}

// MARK: - Pace Category

enum PaceCategory {
    case tooSlow
    case slow
    case ideal
    case fast
    case tooFast
    
    var label: String {
        switch self {
        case .tooSlow: return "Very Slow"
        case .slow: return "Slow"
        case .ideal: return "Ideal"
        case .fast: return "Fast"
        case .tooFast: return "Very Fast"
        }
    }
    
    var color: Color {
        switch self {
        case .tooSlow: return .orange
        case .slow: return .yellow
        case .ideal: return .green
        case .fast: return .yellow
        case .tooFast: return .orange
        }
    }
}

// MARK: - Presentation Feedback

struct PresentationFeedback {
    // Overall
    let overallScore: Int // 0-100
    let tone: FeedbackTone
    let summary: String
    let durationText: String
    
    // Detailed metrics
    let metrics: [DetailedMetric]
    
    // Insights
    let insights: [FeedbackInsight]
    
    // Pace analysis
    let paceCategory: PaceCategory
    let paceDescription: String
    
    // Pause analysis
    let pauseDistribution: PauseDistribution
    
    // Actionable next steps
    let practiceExercises: [PracticeExercise]
}

// MARK: - Pause Distribution

struct PauseDistribution {
    let shortPauses: Int      // < 0.5s
    let mediumPauses: Int     // 0.5s - 1.5s
    let longPauses: Int       // 1.5s - 3s
    let veryLongPauses: Int   // > 3s
    
    var total: Int {
        shortPauses + mediumPauses + longPauses + veryLongPauses
    }
    
    var analysis: String {
        if veryLongPauses > 2 {
            return "You had several extended pauses that may indicate hesitation or lost train of thought."
        } else if longPauses > total / 2 {
            return "Your pauses tend to run long. Strategic shorter pauses can feel more confident."
        } else if shortPauses > total * 2 / 3 {
            return "Your pauses are quick—great for energy, but longer pauses can add emphasis."
        } else {
            return "Good mix of pause lengths, suggesting natural speech rhythm."
        }
    }
}

// MARK: - Practice Exercise

struct PracticeExercise: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let icon: String
}
