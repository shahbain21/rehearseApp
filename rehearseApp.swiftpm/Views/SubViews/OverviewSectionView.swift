import SwiftUI

struct OverviewSection: View {
    let feedback: PresentationFeedback
    let recording: Recording

    var body: some View {
        VStack(spacing: 20) {

            // Score + Tone
            ScoreCard(
                score: feedback.overallScore,
                tone: feedback.tone,
                duration: feedback.durationText
            )

            // Summary
            Text(feedback.summary)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Core metrics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickMetricCard(
                    icon: "waveform",
                    title: "Speaking",
                    value: "\(Int(recording.speakingRatio * 100))%",
                    color: .blue
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

            // Key Insight
            VStack(alignment: .leading, spacing: 12) {
                Text("Key Insight")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))

                ForEach(feedback.insights.prefix(2)) { insight in
                    InsightRow(insight: insight)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}
