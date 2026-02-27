//
//  VocalEnergyView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

import SwiftUI

// Expandable Vocal Energy Card
struct ExpandableVocalEnergyCard: View {
    let samples: [Float]
    @State private var isExpanded = false
    // Get analysis from analyzer
    private var analysis: VolumeAnalysis {
        VolumeAnalysis.analyze(samples)
    }
    var body: some View {
        VStack(spacing: 0) {

            // Compact header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "speaker.wave.3")
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(analysis.isMonotone ? .orange : .green)
                        .frame(width: 24)

                    Text("Vocal Energy")
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)

                    Spacer()
                    // Shows variation in the vocals
                    Text(variationLabel)
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(variationColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(variationColor.opacity(0.15))
                        .cornerRadius(AppTheme.Spacing.sm)
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

                    VolumeWaveform(samples: samples)
                        .frame(height: 60)
                    
                    // Custom Badge for every stat
                    HStack(spacing: AppTheme.Spacing.lg) {
                        VocalStatBadge(
                            label: "Variation",
                            value: analysis.isMonotone ? "Low" :
                                   analysis.variationScore > 70 ? "High" : "Medium",
                            color: analysis.isMonotone ? .orange :
                                   analysis.variationScore > 70 ? .green : .cyan
                        )

                        VocalStatBadge(
                            label: "Range",
                            value: String(format: "%.0f dB", analysis.volumeRange),
                            color: analysis.volumeRange > 15 ? .green : .yellow
                        )

                        VocalStatBadge(
                            label: "Style",
                            value: analysis.isMonotone ? "Flat" : "Dynamic",
                            color: analysis.isMonotone ? .orange : .green
                        )
                    }

                    // Description
                    Text(variationDescription)
                        .font(AppTheme.Fonts.cardSubtitle)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }

    // Functions to get customized feedback
    
    private var variationLabel: String {
        if analysis.isMonotone { return "Monotone" }
        if analysis.variationScore > 70 { return "Dynamic" }
        return "Moderate"
    }

    private var variationColor: Color {
        if analysis.isMonotone { return .orange }
        if analysis.variationScore > 70 { return .green }
        return .cyan
    }

    private var variationDescription: String {
        if analysis.isMonotone {
            return "Your delivery sounds flat — try varying your volume to emphasize key points."
        }
        if analysis.variationScore > 70 {
            return "Great vocal variety! You're naturally emphasizing points with your voice."
        }
        return "Decent variation. Try pushing your emphasis a bit more on key moments."
    }
}

struct VocalStatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}


struct VolumeWaveform: View {
    let samples: [Float]

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 2) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                    let normalized = normalizedHeight(sample)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: normalized))
                        .frame(
                            width: max(2, (geo.size.width - CGFloat(samples.count) * 2) / CGFloat(samples.count)),
                            height: max(4, normalized * geo.size.height)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // Gets the normalized height of the sample
    private func normalizedHeight(_ sample: Float) -> CGFloat {
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        let clamped = max(minDb, min(sample, maxDb))
        return CGFloat((clamped - minDb) / (maxDb - minDb))
    }

    // Selects bar color based off sample
    private func barColor(for normalized: CGFloat) -> Color {
        if normalized > 0.7 { return .green }
        else if normalized > 0.4 { return .cyan }
        else { return AppTheme.mutedText }
    }
}

// Previews

#Preview("Vocal Energy - Collapsed") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableVocalEnergyCard(
            samples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36]
        )
        .padding()
    }
}
