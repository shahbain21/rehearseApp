//
//  ReflectionPromptsSheet.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/26/26.
//

import SwiftUI

struct ReflectionPromptsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let prompts = [
        ReflectionPrompt(
            category: "Delivery",
            questions: [
                "Did I speak at a comfortable pace?",
                "Were my pauses intentional or hesitant?",
                "Did I sound confident?"
            ]
        ),
        ReflectionPrompt(
            category: "Content",
            questions: [
                "Did I cover all my main points?",
                "Were my ideas organized logically?",
                "Did I stay on topic?"
            ]
        ),
        ReflectionPrompt(
            category: "Mindset",
            questions: [
                "How did I feel before starting?",
                "What triggered any nervousness?",
                "When did I feel most confident?"
            ]
        ),
        ReflectionPrompt(
            category: "Growth",
            questions: [
                "What's one thing I did better than last time?",
                "What's one thing I want to improve?",
                "What would I tell someone else in my position?"
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(AppTheme.mutedText)
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                
                // Header
                HStack {
                    Text("Reflection Prompts")
                        .font(AppTheme.Fonts.screenTitle)
                        .foregroundColor(AppTheme.primaryText)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.tertiaryText)
                            // ADDED: Proper tap target
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close prompts")
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
                
                // Prompts
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ForEach(prompts, id: \.category) { prompt in
                            PromptCategoryCard(prompt: prompt)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, 30)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

struct ReflectionPrompt {
    let category: String
    let questions: [String]
}

struct PromptCategoryCard: View {
    let prompt: ReflectionPrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(prompt.category)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundColor(AppTheme.primaryText)
            
            ForEach(prompt.questions, id: \.self) { question in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.top, 6)
                    
                    Text(question)
                        .font(AppTheme.Fonts.screenSubtitle)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
}
