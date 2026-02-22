//
//  PracticeMode.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import Foundation

enum PracticeMode: Codable, Hashable, CaseIterable {
    case interview
    case presentation
    case storytelling
    case free
    
    // Only free doesn't require notes
    var requiresNotes: Bool {
        self != .free
    }
    
    // Display name for the mode
    var displayName: String {
        switch self {
        case .interview:
            return "Interview"
        case .presentation:
            return "Presentation"
        case .storytelling:
            return "Storytelling"
        case .free:
            return "Free Practice"
        }
    }
    
    // Icon for the mode
    var icon: String {
        switch self {
        case .interview:
            return "person.fill.questionmark"
        case .presentation:
            return "chart.bar.doc.horizontal"
        case .storytelling:
            return "book.fill"
        case .free:
            return "mic.fill"
        }
    }
    
    // Subtitle description
    var subtitle: String {
        switch self {
        case .interview:
            return "Answer clearly and confidently"
        case .presentation:
            return "Practice pacing and emphasis"
        case .storytelling:
            return "Work on flow and engagement"
        case .free:
            return "Just speak and reflect"
        }
    }
}
