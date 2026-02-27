//
//  FeedbackComponents.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI


struct ScoreCard: View {
    let score: Int
    let tone: FeedbackTone
    let duration: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(AppTheme.border, lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        tone.color,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)

                    Text("/ 100")
                        .font(AppTheme.Fonts.cardSubtitle)
                        .foregroundColor(AppTheme.tertiaryText)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: tone.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tone.label)
                    .font(AppTheme.Fonts.cardTitle)
            }
            .foregroundColor(tone.color)
            .padding(.horizontal, 14)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(tone.color.opacity(0.15))
            .cornerRadius(20)

            Text(duration)
                .font(AppTheme.Fonts.cardSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
    }
}

// Expandable Metric Card

struct ExpandableMetricCard: View {
    let metric: DetailedMetric
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {

            // Compact header — always visible
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: metric.icon)
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(metric.rating.color)
                        .frame(width: 24)

                    Text(metric.name)
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)

                    Spacer()

                    Text(metric.value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.tertiaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Divider()
                        .overlay(AppTheme.border)
                        .padding(.vertical, AppTheme.Spacing.sm)

                    // Rating badge
                    HStack {
                        Text(metric.description)
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.secondaryText)

                        Spacer()

                        Text(metric.rating.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(metric.rating.color)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(metric.rating.color.opacity(0.15))
                            .cornerRadius(6)
                    }

                    // Tip
                    if let tip = metric.tip {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 10))
                            Text(tip)
                                .font(AppTheme.Fonts.smallLabel)
                        }
                        .foregroundColor(.yellow)
                        .padding(AppTheme.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(AppTheme.Spacing.sm)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
}

// Insight Row

struct InsightRow: View {
    let insight: FeedbackInsight

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: insight.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(insight.type.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(insight.title)
                    .font(AppTheme.Fonts.cardTitle)
                    .foregroundColor(AppTheme.primaryText)

                Text(insight.description)
                    .font(AppTheme.Fonts.cardSubtitle)
                    .foregroundColor(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(insight.type.color.opacity(0.1))
        .cornerRadius(AppTheme.Radius.card)
    }
}

// Previews

#Preview("Score Card") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ScoreCard(score: 78, tone: .good, duration: "2m 5s")
            .padding()
    }
}

#Preview("Expandable Metric") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack(spacing: 12) {
            ExpandableMetricCard(metric: DetailedMetric(
                name: "Speaking Time",
                value: "72%",
                rating: .good,
                description: "Good balance of speaking and pausing",
                tip: "Try to maintain this in longer sessions",
                icon: "waveform"
            ))
            ExpandableMetricCard(metric: DetailedMetric(
                name: "Hesitations",
                value: "3",
                rating: .fair,
                description: "3 pauses over 2 seconds",
                tip: "Practice transitions between your main points",
                icon: "exclamationmark.circle"
            ))
        }
        .padding()
    }
}
