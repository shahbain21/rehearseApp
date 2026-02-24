//
//  FeedbackComponents.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI

// MARK: - Score Card

struct ScoreCard: View {
    let score: Int
    let tone: FeedbackTone
    let duration: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Score ring
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
            
            // Tone badge
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
            
            // Duration
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

// MARK: - Quick Metric Card

struct QuickMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.primaryText)

            Text(title)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.button)
    }
}

// MARK: - Insight Row

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

// MARK: - Detailed Metric Row

struct DetailedMetricRow: View {
    let metric: DetailedMetric

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Header: icon + name + value
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: metric.icon)
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(metric.rating.color)
                        .frame(width: 24)

                    Text(metric.name)
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)
                }

                Spacer()

                Text(metric.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
            }

            // Description + rating badge
            HStack {
                Text(metric.description)
                    .font(AppTheme.Fonts.cardSubtitle)
                    .foregroundColor(AppTheme.tertiaryText)

                Spacer()

                Text(metric.rating.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(metric.rating.color)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(metric.rating.color.opacity(0.15))
                    .cornerRadius(6)
            }

            // Optional tip
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
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.button)
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: PracticeExercise

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.accentMuted)
                    .frame(width: AppTheme.IconSize.cardIcon,
                           height: AppTheme.IconSize.cardIcon)

                Image(systemName: exercise.icon)
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.accent)
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text(exercise.title)
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)

                    Spacer()

                    Text(exercise.duration)
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(6)
                }

                Text(exercise.description)
                    .font(AppTheme.Fonts.cardSubtitle)
                    .foregroundColor(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.button)
    }
}

// MARK: - Component Previews

#Preview("Score Card") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ScoreCard(score: 78, tone: .good, duration: "2m 5s")
            .padding()
    }
}

#Preview("Quick Metrics") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        HStack(spacing: 12) {
            QuickMetricCard(
                icon: "waveform",
                title: "Speaking",
                value: "72%",
                color: .blue
            )
            QuickMetricCard(
                icon: "exclamationmark.circle",
                title: "Hesitations",
                value: "3",
                color: .orange
            )
        }
        .padding()
    }
}

#Preview("Insight Row") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack(spacing: 12) {
            InsightRow(insight: FeedbackInsight(
                type: .strength,
                title: "Great Speaking Balance",
                description: "You maintained an ideal balance between speaking and pausing."
            ))
            InsightRow(insight: FeedbackInsight(
                type: .improvement,
                title: "Reduce Hesitations",
                description: "You had 3 pauses over 2 seconds. Practice transitions."
            ))
            InsightRow(insight: FeedbackInsight(
                type: .tip,
                title: "Try Longer Sessions",
                description: "2-5 minute sessions give more reliable feedback."
            ))
        }
        .padding()
    }
}

#Preview("Detailed Metric") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        DetailedMetricRow(metric: DetailedMetric(
            name: "Speaking Time",
            value: "72%",
            rating: .good,
            description: "Good balance of speaking and pausing",
            tip: "Try to maintain this in longer sessions",
            icon: "waveform"
        ))
        .padding()
    }
}

#Preview("Exercise Card") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExerciseCard(exercise: PracticeExercise(
            title: "Bridge Phrases",
            description: "Practice transitions like 'Building on that...' to fill pauses.",
            duration: "3 min",
            icon: "link"
        ))
        .padding()
    }
}
