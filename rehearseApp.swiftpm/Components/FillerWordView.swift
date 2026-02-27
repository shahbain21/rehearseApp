//
//  FillerWordCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/19/26.
//

import SwiftUI

struct ExpandableFillerWordCard: View {
    let result: FillerWordResult
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
                    Image(systemName: "text.bubble")
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(result.rating.color)
                        .frame(width: 24)

                    Text("Filler Words")
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)

                    Spacer()

                    if result.isEmpty {
                        Text("None")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    } else {
                        Text("\(result.total)")
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

                    // Per-minute badge
                    HStack {
                        Text("Rate")
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.secondaryText)

                        Spacer()

                        Text(String(format: "%.1f/min", result.perMinute))
                            .font(AppTheme.Fonts.smallLabel)
                            .foregroundColor(result.rating.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(result.rating.color.opacity(0.15))
                            .cornerRadius(AppTheme.Spacing.sm)
                    }

                    if result.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("No filler words detected!")
                                .font(AppTheme.Fonts.cardSubtitle)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    } else {
                        // Word breakdown
                        ForEach(result.sorted, id: \.word) { word, count in
                            fillerRow(word: word, count: count)
                        }

                        // Description
                        Text(ratingDescription)
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

    private func fillerRow(word: String, count: Int) -> some View {
        HStack {
            Text("\"\(word)\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.primaryText)
            Spacer()
            let maxCount = result.sorted.first?.count ?? 1
            RoundedRectangle(cornerRadius: 3)
                .fill(result.rating.color.opacity(0.6))
                .frame(
                    width: max(8, CGFloat(count) / CGFloat(maxCount) * 80),
                    height: 8
                )
            Text("\(count)×")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(result.rating.color)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private var ratingDescription: String {
        switch result.rating {
        case .clean:     return "Perfect! No filler words detected."
        case .excellent: return "Very clean speech. Minimal filler usage."
        case .good:      return "Good control. A few fillers but nothing distracting."
        case .fair:      return "Noticeable filler usage. Try pausing instead of filling."
        case .heavy:     return "Frequent fillers. Practice replacing them with brief pauses."
        }
    }
}

// Previews

#Preview("Clean") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableFillerWordCard(result: FillerWordResult(
            counts: [:], total: 0, perMinute: 0, duration: 120
        ))
        .padding()
    }
}

#Preview("Moderate") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableFillerWordCard(result: FillerWordResult(
            counts: ["um": 4, "like": 7, "you know": 3],
            total: 14, perMinute: 3.8, duration: 220
        ))
        .padding()
    }
}
