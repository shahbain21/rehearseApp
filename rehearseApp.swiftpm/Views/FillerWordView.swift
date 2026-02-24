//
//  FillerWordCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/19/26.
//

import SwiftUI

struct FillerWordCard: View {
    let result: FillerWordResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {

            // Header
            HStack {
                Image(systemName: "text.bubble")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(result.rating.color)

                Text("Filler Words")
                    .font(AppTheme.Fonts.cardTitle)
                    .foregroundColor(AppTheme.primaryText)

                Spacer()

                // Per-minute badge
                Text(String(format: "%.1f/min", result.perMinute))
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(result.rating.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(result.rating.color.opacity(0.15))
                    .cornerRadius(AppTheme.Spacing.sm)
            }

            // Content
            if result.isEmpty {
                // Clean speech
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No filler words detected!")
                        .font(AppTheme.Fonts.cardSubtitle)
                        .foregroundColor(AppTheme.secondaryText)
                }
            } else {
                // Filler breakdown
                ForEach(result.sorted, id: \.word) { word, count in
                    fillerRow(word: word, count: count)
                }

                // Total
                HStack {
                    Text("Total")
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)

                    Spacer()

                    Text("\(result.total) fillers")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                }
                .padding(.top, AppTheme.Spacing.xs)

                // Rating description
                Text(ratingDescription)
                    .font(AppTheme.Fonts.cardSubtitle)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }

    // MARK: - Row

    private func fillerRow(word: String, count: Int) -> some View {
        HStack {
            Text("\"\(word)\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.primaryText)

            Spacer()

            // Mini bar
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

    // MARK: - Description

    private var ratingDescription: String {
        switch result.rating {
        case .clean:
            return "Perfect! No filler words detected."
        case .excellent:
            return "Very clean speech. Minimal filler usage."
        case .good:
            return "Good control. A few fillers but nothing distracting."
        case .fair:
            return "Noticeable filler usage. Try pausing instead of filling."
        case .heavy:
            return "Frequent fillers. Practice replacing them with brief pauses."
        }
    }
}

// MARK: - Previews

#Preview("Clean Speech") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        FillerWordCard(result: FillerWordResult(
            counts: [:],
            total: 0,
            perMinute: 0,
            duration: 120
        ))
        .padding()
    }
}

#Preview("Moderate Fillers") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        FillerWordCard(result: FillerWordResult(
            counts: ["um": 4, "like": 7, "you know": 3, "basically": 2],
            total: 16,
            perMinute: 3.8,
            duration: 252
        ))
        .padding()
    }
}

#Preview("Heavy Fillers") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        FillerWordCard(result: FillerWordResult(
            counts: ["um": 12, "uh": 8, "like": 15, "you know": 6, "so": 9],
            total: 50,
            perMinute: 8.3,
            duration: 360
        ))
        .padding()
    }
}
