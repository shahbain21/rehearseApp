//
//  AppTheme.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/6/26.
//
import SwiftUI

struct AppTheme {
    // Background colors
    static let background = Color(hex: "141424")
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

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: 
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
