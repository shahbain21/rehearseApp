//
//  ReflectionSummaryCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI

// ADDED: Displays a saved reflection inside FeedbackView
// Shows mood, tags, and optional note in a clean card format

struct ReflectionSummaryCard: View {
    let reflection: Reflection
    
    // ADDED: Map mood string back to the enum for emoji/color
    private var mood: ReflectionMood? {
        ReflectionMood.allCases.first { $0.label == reflection.mood }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            
            // Section header
            Text("YOUR REFLECTION")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.8)
            
            // Mood row
            if let mood = mood {
                HStack(spacing: AppTheme.Spacing.md) {
                    Text(mood.emoji)
                        .font(.system(size: 24))
                    
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
            
            // Tags
            if !reflection.tags.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("What stood out")
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)
                    
                    // ADDED: Wrap tags in a flow layout
                    FlowLayout(spacing: 6) {
                        ForEach(reflection.tags, id: \.self) { tag in
                            Text(tag)
                                .font(AppTheme.Fonts.smallLabel)
                                .foregroundColor(AppTheme.accent)
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppTheme.accentMuted)
                                )
                        }
                    }
                }
            }
            
            // Note
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
    
    // ADDED: Relative time since reflection
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
                tags: ["Good energy", "Stayed calm", "Strong opening"],
                note: "I felt really prepared this time, the breathing exercise helped.",
                date: Date().addingTimeInterval(-3600)
            )
        )
        .padding()
    }
}
