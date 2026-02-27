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
    static let mutedText = Color.white.opacity(0.3)
    
    // Accent colors
    static let accent = Color.blue
    static let accentMuted = Color.blue.opacity(0.2)
    static let destructive = Color.red
    
    // Border colors
    static let border = Color.white.opacity(0.1)
    static let borderSelected = Color.blue.opacity(0.5)
    
    static func modeColor(for mode: PracticeMode) -> Color {
        switch mode {
        case .interview:    return Color(hex: "6E9BFF")
        case .presentation: return Color(hex: "9B8FCC")
        case .storytelling: return Color(hex: "CCB080")
        case .free:         return Color(hex: "7FBFA4") 
        }
    }
    
    // Spacing Constants
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 40
    }
    
    // Corner radius constants
    enum Radius {
        static let card: CGFloat = 16
        static let button: CGFloat = 14
    }
    
    // Icon Size Constants
    enum IconSize {
        static let cardIcon: CGFloat = 44
        static let selectionOuter: CGFloat = 24
        static let selectionInner: CGFloat = 14
    }
    
    // Scalable, dynamic, fonts
    enum Fonts {
        static let navTitle = Font.headline.weight(.semibold)
        static let screenTitle = Font.title2.weight(.semibold)
        static let screenSubtitle = Font.subheadline
        static let cardTitle = Font.subheadline.weight(.semibold)
        static let cardSubtitle = Font.caption
        static let buttonLabel = Font.body.weight(.semibold)
        static let secondaryButton = Font.subheadline.weight(.medium)
        static let iconFont = Font.system(size: 18, weight: .medium)
        static let smallLabel = Font.caption2.weight(.medium)
        static let caption = Font.caption
    }
}

// Reusable button Animation
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Custom background modifier
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
