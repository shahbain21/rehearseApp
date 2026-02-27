//
//  RepeatedPhraseCard.swift
//  rehearseApp
//

import SwiftUI

struct ExpandableRepeatedPhraseCard: View {
    let result: RepeatedPhraseResult
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {

            // Compact header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(result.rating.color)
                        .frame(width: 24)

                    Text("Repeated Phrases")
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)

                    Spacer()

                    if result.isEmpty {
                        Text("None")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    } else {
                        Text("\(result.phrases.count)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.tertiaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Divider()
                        .overlay(AppTheme.border)
                        .padding(.vertical, AppTheme.Spacing.sm)

                    if result.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("No repeated phrases detected!")
                                .font(AppTheme.Fonts.cardSubtitle)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    } else {
                        // Shows phrase and number of occurences
                        ForEach(result.phrases) { phrase in
                            phraseRow(phrase)
                        }

                        // Description
                        Text(result.rating.description)
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.secondaryText)
                            .padding(.top, AppTheme.Spacing.xs)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }

    private func phraseRow(_ phrase: RepeatedPhrase) -> some View {
        HStack {
            Text("\"\(phrase.phrase)\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)

            Spacer()

            let maxCount = result.phrases.first?.count ?? 1
            RoundedRectangle(cornerRadius: 3)
                .fill(result.rating.color.opacity(0.6))
                .frame(
                    width: max(8, CGFloat(phrase.count) / CGFloat(maxCount) * 80),
                    height: 8
                )

            Text("\(phrase.count)×")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(result.rating.color)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

// Previews

#Preview("Clean") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableRepeatedPhraseCard(result: RepeatedPhraseResult(
            phrases: [], totalRepeats: 0, duration: 120
        ))
        .padding()
    }
}

#Preview("Moderate") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableRepeatedPhraseCard(result: RepeatedPhraseResult(
            phrases: [
                RepeatedPhrase(phrase: "the thing is", count: 4, wordCount: 3),
                RepeatedPhrase(phrase: "moving forward", count: 2, wordCount: 2)
            ],
            totalRepeats: 4, duration: 180
        ))
        .padding()
    }
}
