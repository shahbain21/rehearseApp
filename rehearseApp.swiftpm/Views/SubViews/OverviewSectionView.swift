//
//  OverviewSectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//
import SwiftUI

struct OverviewSection: View {
    let feedback: PresentationFeedback
    let recording: Recording
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScoreCard(
                score: feedback.overallScore,
                tone: feedback.tone,
                duration: feedback.durationText
            )
            
            Text(feedback.summary)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            PaceIndicator(category: feedback.paceCategory, description: feedback.paceDescription)
            
            // Quick metrics grid (existing — unchanged)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickMetricCard(
                    icon: "waveform",
                    title: "Speaking",
                    value: "\(Int(recording.speakingRatio * 100))%",
                    color: .blue
                )
                
                QuickMetricCard(
                    icon: "pause.circle",
                    title: "Avg Pause",
                    value: String(format: "%.1fs", recording.averagePauseDuration),
                    color: .cyan
                )
                
                QuickMetricCard(
                    icon: "text.alignleft",
                    title: "Avg Segment",
                    value: String(format: "%.1fs", recording.averageSpeakingSegmentLength),
                    color: .purple
                )
                
                QuickMetricCard(
                    icon: "exclamationmark.circle",
                    title: "Long Pauses",
                    value: "\(recording.longPauseCount)",
                    color: recording.longPauseCount > 2 ? .orange : .green
                )
            }
            
            if let samples = recording.volumeSamples, !samples.isEmpty {
                VocalEnergySummary(samples: samples)
            }
            
            // Key Insights (existing — unchanged)
            VStack(alignment: .leading, spacing: 12) {
                Text("Key Insights")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                ForEach(feedback.insights.prefix(3)) { insight in
                    InsightRow(insight: insight)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}
