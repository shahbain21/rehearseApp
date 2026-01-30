//
//  PracticeMode.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//
enum PracticeMode {
    case interview
    case presentation
    case storytelling
    case free
}

extension PracticeMode {
    var requiresNotes: Bool {
        switch self {
        case .presentation, .storytelling:
            return true
        case .interview, .free:
            return false
        }
    }
}
