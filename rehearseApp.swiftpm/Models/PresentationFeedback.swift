//
//  PresentationFeedback.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//
import SwiftUI


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

struct DetailedMetric {
    let name: String
    let value: String
    let rating: MetricRating
    let description: String
    let tip: String?
    let icon: String
}

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


struct PresentationFeedback {
    let overallScore: Int
    let tone: FeedbackTone
    let summary: String
    let durationText: String
    let metrics: [DetailedMetric]
    let insights: [FeedbackInsight]
}
