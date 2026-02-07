//
//  AppScreen.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//
enum AppScreen {
    case home
    case notes(PracticeMode)
    case grounding(PracticeMode)
    case recording(PracticeMode)
    case feedback(Recording)
    case history
    case reflection(Recording?)  // ✅ Updated to include optional recording
}


// Make Recording conform to Hashable for AppScreen
extension Recording: Hashable {
    static func == (lhs: Recording, rhs: Recording) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
