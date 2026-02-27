//
//  ReflectionSummaryCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI


struct ReflectionSummaryCard: View {
    let reflection: Reflection
    
    // Gets the mood from the session
    private var mood: ReflectionMood? {
        ReflectionMood.allCases.first { $0.label == reflection.mood }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            
            Text("YOUR REFLECTION")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.8)
            
            // Displays mood from feedback as well as label and time
            if let mood = mood {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: mood.symbol)
                            .font(.system(size: 24, weight: .semibold))
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("You felt \(mood.label.lowercased())")
                            .font(AppTheme.Fonts.cardTitle)
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text(reflectionTimeAgo)
                            .font(AppTheme.Fonts.smallLabel)
                            .foregroundColor(AppTheme.mutedText)
                    }
                    Spacer()
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .fill(mood.color.opacity(0.1))
                )
            }
            
            // Note from the session
            if !reflection.note.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Note")
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)
                    
                    Text("\"\(reflection.note)\"")
                        .font(AppTheme.Fonts.screenSubtitle)
                        .foregroundColor(AppTheme.secondaryText)
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .fill(AppTheme.cardBackground)
                )
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
    
    private var reflectionTimeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Reflected " + formatter.localizedString(for: reflection.date, relativeTo: Date())
    }
}

#Preview("Reflection Summary") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        
        ReflectionSummaryCard(
            reflection: Reflection(
                mood: "Great",
                note: "I felt really prepared this time, the breathing exercise helped.",
                date: Date().addingTimeInterval(-3600)
            )
        )
        .padding()
    }
}
