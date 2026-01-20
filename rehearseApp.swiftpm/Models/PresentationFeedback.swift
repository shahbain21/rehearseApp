//
//  PresentationFeedback.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/8/26.
//
import SwiftUI

enum FeedbackTone {
    case positive
    case neutral
    case needsWork

    var color: Color {
        switch self {
        case .positive: return .green
        case .neutral: return .blue
        case .needsWork: return .orange
        }
    }

    var label: String {
        switch self {
        case .positive: return "Strong delivery"
        case .neutral: return "Steady pace"
        case .needsWork: return "Needs refinement"
        }
    }
}

struct PresentationFeedback {
    let summary: String
    let tone: FeedbackTone
    let whatWentWell: String
    let improvementSuggestion: String
    let durationText: String
}
