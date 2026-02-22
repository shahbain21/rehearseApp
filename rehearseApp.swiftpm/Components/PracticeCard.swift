//
//  PracticeCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct PracticeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.lg) {
                iconCircle
                textContent
                Spacer()
                selectionIndicator
            }
            .padding(AppTheme.Spacing.lg)
            .background(cardBackground)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // Individual struct for icon circle
    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(isSelected ? accentColor.opacity(0.2): accentColor.opacity(0.08))
                .frame(width: AppTheme.IconSize.cardIcon, height: AppTheme.IconSize.cardIcon)
            
            Image(systemName: icon)
                .font(AppTheme.Fonts.iconFont)
                .foregroundColor(isSelected ? AppTheme.accent : AppTheme.secondaryText)
        }
    }
    
    // Individual struct for the text
    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundColor(AppTheme.primaryText)

            Text(subtitle)
                .font(AppTheme.Fonts.cardSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
        }
    }
    
    // Individual struct for the selection indicator circles
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? accentColor : AppTheme.mutedText, lineWidth: 2)
                .frame(width: AppTheme.IconSize.selectionOuter,
                       height: AppTheme.IconSize.selectionOuter)
            
            if isSelected {
                Circle()
                    .fill(accentColor)
                    .frame(width: AppTheme.IconSize.selectionInner,
                           height: AppTheme.IconSize.selectionInner)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // Individual struct for the background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
            .fill(isSelected ? accentColor.opacity(0.12) : AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(isSelected ? accentColor.opacity(0.4) : AppTheme.border,
                            lineWidth: 1)
            )
    }
}

#Preview("Practice Card") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.md) {
            // CHANGED: Preview now shows different mode colors
            PracticeCard(
                icon: "person.fill.questionmark",
                title: "Interview",
                subtitle: "Answer clearly and confidently",
                isSelected: true,
                accentColor: .blue
            ) {}
            
            PracticeCard(
                icon: "chart.bar.doc.horizontal",
                title: "Presentation",
                subtitle: "Practice pacing and emphasis",
                isSelected: false,
                accentColor: .purple
            ) {}
            
            PracticeCard(
                icon: "book.fill",
                title: "Storytelling",
                subtitle: "Work on flow and engagement",
                isSelected: false,
                accentColor: .orange
            ) {}
        }
        .padding()
    }
}
