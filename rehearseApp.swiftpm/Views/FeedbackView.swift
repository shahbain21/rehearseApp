//
//  FeedbackView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//
import SwiftUI

// MARK: - FeedbackView

struct FeedbackView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording
    @ObservedObject var audioManager: AudioManager

    @State private var selectedTab: FeedbackTab = .overview
    @State private var feedback: PresentationFeedback?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let feedback {
                VStack(spacing: 0) {

                    // Top bar
                    HStack {
                        Button {
                            currentScreen = .history
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Spacer()

                        Text("Feedback")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            audioManager.togglePlayback(for: recording)
                        } label: {
                            Image(systemName: audioManager.currentlyPlayingID == recording.id ? "stop.fill" : "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)

                    FeedbackTabSelector(selectedTab: $selectedTab)
                        .padding(.horizontal)
                        .padding(.bottom, 16)

                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case .overview:
                                OverviewSection(feedback: feedback, recording: recording)
                            case .details:
                                DetailsSection(feedback: feedback, recording: recording)
                            case .improve:
                                ImproveSection(feedback: feedback, onReflect: {
                                    currentScreen = .reflection(recording)
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .onAppear {
            if feedback == nil {
                feedback = FeedbackGenerator.generate(from: recording)
            }
        }
    }
}

// MARK: - Quick Metric Card

struct QuickMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let insight: FeedbackInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(insight.type.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(insight.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(insight.type.color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Details Section

struct DetailsSection: View {
    let feedback: PresentationFeedback
    let recording: Recording

    var body: some View {
        VStack(spacing: 20) {

            // Detailed metrics
            VStack(alignment: .leading, spacing: 12) {
                Text("Metrics")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))

                ForEach(feedback.metrics, id: \.name) { metric in
                    DetailedMetricRow(metric: metric)
                }
            }

            // Volume waveform
            if let samples = recording.volumeSamples, !samples.isEmpty {
                VocalEnergyDetailCard(samples: samples)
            }

            // Insights
            VStack(alignment: .leading, spacing: 12) {
                Text("Insights")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))

                ForEach(feedback.insights) { insight in
                    InsightRow(insight: insight)
                }
            }
        }
    }
}

// MARK: - Detailed Metric Row

struct DetailedMetricRow: View {
    let metric: DetailedMetric

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: metric.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(metric.rating.color)
                        .frame(width: 24)

                    Text(metric.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(metric.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack {
                Text(metric.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                Text(metric.rating.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(metric.rating.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(metric.rating.color.opacity(0.15))
                    .cornerRadius(6)
            }

            if let tip = metric.tip {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 10))
                    Text(tip)
                        .font(.system(size: 12))
                }
                .foregroundColor(.yellow)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Previews

#Preview("Feedback View") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5, 0.9, 1.1, 0.5, 3.2, 0.7],
        notes: "My presentation notes",
        volumeSamples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36]
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}

#Preview("Feedback - Needs Work") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 60,
        speakingTime: 25,
        pauses: [2.1, 3.5, 2.8, 4.2, 1.9, 2.5],
        notes: nil,
        volumeSamples: [-42, -44, -43, -45, -42, -44, -43, -42]
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}
