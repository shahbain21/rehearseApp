//
//  FeedbackSections.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI

// MARK: - Overview Section

struct OverviewSection: View {
    let feedback: PresentationFeedback
    let recording: Recording

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {

            // Score + Tone
            ScoreCard(
                score: feedback.overallScore,
                tone: feedback.tone,
                duration: feedback.durationText
            )

            // Summary
            Text(feedback.summary)
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)

            // Core metrics
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppTheme.Spacing.md
            ) {
                QuickMetricCard(
                    icon: "waveform",
                    title: "Speaking",
                    value: "\(Int(recording.speakingRatio * 100))%",
                    color: AppTheme.accent
                )

                QuickMetricCard(
                    icon: "exclamationmark.circle",
                    title: "Hesitations",
                    value: "\(recording.longPauseCount)",
                    color: recording.longPauseCount > 2 ? .orange : .green
                )
            }

            // Volume summary
            if let samples = recording.volumeSamples, !samples.isEmpty {
                VocalEnergySummary(samples: samples)
            }

            // Filler words
            if let transcript = recording.transcript {
                FillerWordCard(
                    result: FillerWordAnalyzer.analyze(transcript)
                )
            }

            // Key Insight
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("KEY INSIGHT")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.8)

                ForEach(feedback.insights.prefix(2)) { insight in
                    InsightRow(insight: insight)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Radius.card)
        }
    }
}

// MARK: - Details Section

struct DetailsSection: View {
    let feedback: PresentationFeedback
    let recording: Recording

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {

            // Detailed metrics
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("METRICS")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.8)

                ForEach(feedback.metrics, id: \.name) { metric in
                    DetailedMetricRow(metric: metric)
                }
            }

            // Volume waveform
            if let samples = recording.volumeSamples, !samples.isEmpty {
                VocalEnergyDetailCard(samples: samples)
            }

            // Filler words detail
            if let transcript = recording.transcript {
                FillerWordCard(
                    result: FillerWordAnalyzer.analyze(transcript)
                )
            }

            // Insights
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("INSIGHTS")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.8)

                ForEach(feedback.insights) { insight in
                    InsightRow(insight: insight)
                }
            }
        }
    }
}

// MARK: - Improve Section

struct ImproveSection: View {
    let feedback: PresentationFeedback
    let onReflect: () -> Void
    let onPracticeAgain: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {

            // Practice exercises
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("RECOMMENDED EXERCISE")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.8)

                ForEach(feedback.exercises) { exercise in
                    ExerciseCard(exercise: exercise)
                }
            }

            // Improvement insights
            let improvementInsights = feedback.insights.filter { $0.type == .improvement }
            if !improvementInsights.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("FOCUS AREA")
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)
                        .tracking(0.8)

                    ForEach(improvementInsights) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }

            // Reflect button
            Button(action: onReflect) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Reflect on This Session")
                }
                .font(AppTheme.Fonts.buttonLabel)
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(AppTheme.accent)
                )
            }
            .accessibilityHint("Opens the reflection screen for this session")

            // Practice again
            Button(action: onPracticeAgain) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Practice Again")
                }
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .accessibilityHint(
                "Starts a new practice session with the same mode"
            )
        }
    }
}

// MARK: - Previews

#Preview("Overview") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5],
        notes: nil,
        volumeSamples: [-35, -28, -42, -30, -25]
    )
    let feedback = FeedbackGenerator.generate(from: recording)

    ZStack {
        AppTheme.background.ignoresSafeArea()
        ScrollView {
            OverviewSection(feedback: feedback, recording: recording)
                .padding()
        }
    }
}

#Preview("Details") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5],
        notes: nil,
        volumeSamples: [-35, -28, -42, -30, -25]
    )
    let feedback = FeedbackGenerator.generate(from: recording)

    ZStack {
        AppTheme.background.ignoresSafeArea()
        ScrollView {
            DetailsSection(feedback: feedback, recording: recording)
                .padding()
        }
    }
}

#Preview("Improve") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 60,
        speakingTime: 25,
        pauses: [2.1, 3.5, 2.8],
        notes: nil
    )
    let feedback = FeedbackGenerator.generate(from: recording)

    ZStack {
        AppTheme.background.ignoresSafeArea()
        ScrollView {
            ImproveSection(
                feedback: feedback,
                onReflect: {},
                onPracticeAgain: {}
            )
            .padding()
        }
    }
}
