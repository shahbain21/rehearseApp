//
//  AppTheme.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/6/26.
//
import SwiftUI

struct AppTheme {
    // Background colors
    static let background = Color(red: 0.08, green: 0.08, blue: 0.14)
    static let cardBackground = Color.white.opacity(0.05)
    static let cardBackgroundSelected = Color.blue.opacity(0.15)
    
    // Text colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.5)
    
    // Accent colors
    static let accent = Color.blue
    static let destructive = Color.red
    
    // Border colors
    static let border = Color.white.opacity(0.1)
    static let borderSelected = Color.blue.opacity(0.5)
}

// Usage extension for easy background application
extension View {
    func appBackground() -> some View {
        self.background(AppTheme.background.ignoresSafeArea())
    }
}
