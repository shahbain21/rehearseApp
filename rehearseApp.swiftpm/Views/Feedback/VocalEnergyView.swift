//
//  VocalEnergyView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//


import SwiftUI

// MARK: - Vocal Energy Summary
// Used in OverviewSection — compact version

struct VocalEnergySummary: View {
    let samples: [Float]
    
    private var analysis: VolumeAnalysis {
        VolumeAnalysis.analyze(samples)
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "speaker.wave.3")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(analysis.isMonotone ? .orange : .green)
                
                Text("Vocal Energy")
                    .font(AppTheme.Fonts.cardTitle)
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
                
                Text(variationLabel)
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(variationColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(variationColor.opacity(0.15))
                    .cornerRadius(AppTheme.Spacing.sm)
            }
            
            // Mini waveform
            VolumeWaveform(samples: samples)
                .frame(height: 40)
            
            // Description
            Text(variationDescription)
                .font(AppTheme.Fonts.cardSubtitle)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
    
    // MARK: - Helpers
    
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

// MARK: - Vocal Energy Detail Card
// Used in DetailsSection — expanded version with stats

struct VocalEnergyDetailCard: View {
    let samples: [Float]
    
    private var analysis: VolumeAnalysis {
        VolumeAnalysis.analyze(samples)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // Header
            Text("VOCAL ENERGY")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.8)
            
            // Waveform
            VolumeWaveform(samples: samples)
                .frame(height: 60)
            
            // Stats row
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
            Text(detailDescription)
                .font(AppTheme.Fonts.cardSubtitle)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
    
    private var detailDescription: String {
        if analysis.isMonotone {
            return "Your volume stays very consistent throughout. Varying your loudness helps emphasize key points and keeps listeners engaged."
        }
        if analysis.variationScore > 70 {
            return "Excellent vocal dynamics! You naturally vary your volume, which makes your delivery engaging and expressive."
        }
        return "You have some vocal variation. Try pushing your emphasis a bit more — get louder for key points, softer for reflective moments."
    }
}

// MARK: - Vocal Stat Badge

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

// MARK: - Volume Waveform
// Renders dB samples as colored bars

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
    
    // Map dB range (-60...0) to 0...1
    private func normalizedHeight(_ sample: Float) -> CGFloat {
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        let clamped = max(minDb, min(sample, maxDb))
        return CGFloat((clamped - minDb) / (maxDb - minDb))
    }
    
    // Color based on volume level
    private func barColor(for normalized: CGFloat) -> Color {
        if normalized > 0.7 {
            return .green
        } else if normalized > 0.4 {
            return .cyan
        } else {
            return AppTheme.mutedText
        }
    }
}

// MARK: - Previews

#Preview("Vocal Energy Summary") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VocalEnergySummary(
            samples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36]
        )
        .padding()
    }
}

#Preview("Vocal Energy Detail") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VocalEnergyDetailCard(
            samples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36]
        )
        .padding()
    }
}

#Preview("Volume Waveform") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VolumeWaveform(
            samples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36, -34, -26, -41]
        )
        .frame(height: 60)
        .padding()
    }
}
